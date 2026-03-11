with orders as (

    select * from {{ ref('stg_jaffle_shop__orders') }}

),

customers as (

    select * from {{ ref('stg_jaffle_shop__customers') }}

),

enriched as (

    select
        orders.order_id,
        orders.customer_id,
        orders.order_date,
        orders.status,
        orders.amount,
        orders.payment_method,
        customers.first_name,
        customers.last_name,
        customers.email,
        customers.country

    from orders
    left join customers on orders.customer_id = customers.customer_id

)

select * from enriched
