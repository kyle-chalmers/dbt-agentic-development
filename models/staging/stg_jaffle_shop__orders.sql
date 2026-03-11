with source as (

    select * from {{ ref('raw_orders') }}

),

renamed as (

    select
        id          as order_id,
        user_id     as customer_id,
        order_date,
        status,
        amount,
        payment_method

    from source

)

select * from renamed
