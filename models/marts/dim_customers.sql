with orders as (

    select * from {{ ref('int_orders_enriched') }}

),

customer_aggregates as (

    select
        customer_id,
        first_name,
        last_name,
        email,
        country,

        -- Order volume
        count(order_id)                                         as total_orders,
        sum(amount)                                             as total_revenue,
        avg(amount)                                             as avg_order_value,

        -- Date span
        min(order_date)                                         as first_order_date,
        max(order_date)                                         as most_recent_order_date,

        -- Preferred payment method (most frequent)
        mode(payment_method)                                    as preferred_payment_method,

        -- Completed order metrics
        count(order_id) filter (where status = 'completed')    as completed_orders,
        sum(amount)     filter (where status = 'completed')    as completed_revenue,

        -- Return count
        count(order_id) filter (
            where status in ('return_pending', 'returned')
        )                                                       as return_count

    from orders
    group by
        customer_id,
        first_name,
        last_name,
        email,
        country

)

select
    customer_id,
    first_name,
    last_name,
    email,
    country,
    total_orders,
    round(total_revenue, 2)      as total_revenue,
    round(avg_order_value, 2)    as avg_order_value,
    first_order_date,
    most_recent_order_date,
    preferred_payment_method,
    completed_orders,
    round(completed_revenue, 2)  as completed_revenue,
    return_count,
    case
        when total_revenue >= 1000 then 'Gold'
        when total_revenue >= 500  then 'Silver'
        else                            'Bronze'
    end                          as customer_segment

from customer_aggregates
