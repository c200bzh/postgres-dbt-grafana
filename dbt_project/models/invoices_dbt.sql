{{ config(materialized='table') }}

with source as (
    select *
    from {{ source("public", 'invoice') }}
),

-- Step 1: Handle payloads that are JSON arrays by expanding them into individual rows
expanded_array_payloads as (
    select 
        (jsonb_array_elements(payload::jsonb)) as valid_payload
    from source
    where jsonb_typeof(payload::jsonb) = 'array'
),

-- Step 2: Handle payloads that are JSON objects directly
single_object_payloads as (
    select 
        payload::jsonb as valid_payload
    from source
    where jsonb_typeof(payload::jsonb) = 'object'
),

-- Step 3: Combine both expanded arrays and single objects into one set
all_payloads as (
    select * from expanded_array_payloads
    union all
    select * from single_object_payloads
),

-- Step 4: Extract fields from the JSON data
json_extracted as (
    select 
        valid_payload,
        (valid_payload ->> 'id')::numeric as event_id,
        
        -- Adjust date parsing for multiple formats
        case
            when (valid_payload ->> 'date') ~ '^\d{4}-\d{2}-\d{2}$' 
                then (valid_payload ->> 'date')::date
            when (valid_payload ->> 'date') ~ '^\d{4}/\d{2}/\d{2}$'
                then to_date(valid_payload ->> 'date', 'YYYY/MM/DD')
            when (valid_payload ->> 'date') ~ '^[A-Za-z]{3} \d{2},\d{4}$'
                then to_date(valid_payload ->> 'date', 'Mon DD,YYYY')
            when (valid_payload ->> 'date') ~ '^\d{4}-\d{1,2}-\d{1,2}$'
                then to_date(
                    regexp_replace(valid_payload ->> 'date', 
                                   '^(\d{4})-(\d{1,2})-(\d{1,2})$', 
                                   '\1-' || lpad('\2', 2, '0') || '-' || lpad('\3', 2, '0')),
                    'YYYY-MM-DD'
                )
            else null
        end as event_date,

        (valid_payload ->> 'department') as event_department,

        -- Convert amount to USD based on currency
        case 
            when (valid_payload ->> 'currency') = 'USD' then (valid_payload ->> 'amount')::numeric
            when (valid_payload ->> 'currency') = 'EUR' then (valid_payload ->> 'amount')::numeric * 1.06  -- conversion rate
            when (valid_payload ->> 'currency') = 'AOA' then (valid_payload ->> 'amount')::numeric * 0.0011 -- conversion rate
            else null
        end as amount_usd
    from all_payloads
)

select 
    *,
    date_trunc('month', event_date) as month_year
from json_extracted
