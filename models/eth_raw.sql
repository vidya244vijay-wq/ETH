{{ config(materialized='incremental',incremental_strategy='append')}}

with whale_address_alert as (
select
cast(T.$1:block_hash as string) as block_hash,
cast(T.$1:block_number as integer) as block_number,
cast(T.$1:block_timestamp as timestamp) as block_timestamp,
cast(T.$1:to_address as string) as to_address,
cast(T.$1:value as float) as value
from {{ source('ETH', 'ETH_TRANSACTIONS_RAW') }} T

{% if is_incremental() %}

WHERE block_timestamp >= (select max(block_timestamp) from {{ this }} )

{% endif %}
)
select sum(A.value) as total_value,
A.to_address as address
from whale_address_alert A
group by A.to_address
having sum(A.value) > (100 * 1e18)
