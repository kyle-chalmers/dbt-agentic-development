with source as (

    select * from {{ ref('raw_customers') }}

),

renamed as (

    select
        id          as customer_id,
        first_name,
        last_name,
        email,
        country

    from source

)

select * from renamed
