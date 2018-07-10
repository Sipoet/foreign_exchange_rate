# Description
foreign exchange rate for training with normalization database

# List
* Step to build environment
* structure database
* 

# Step to build environment
* `docker-compose build`
* `docker-compose up`
* if database not created run `docker-compose run web rails db:create`
* if table in database not created run `docker-compose run web rails db:migrate`

# structure database
* table "currencies"
  * description: store currency code
  * id(integer, primary key, not null)|code(vchar, not null)
     --|--
      1|USD
      2|IDR
      3|GBP
* table "exchange_rates"
  * description: store exchange rate list
  * id(integer, primary key, not null)|code(vchar, not null)|from_currency_id(integer, foreign key currencies, not null)|to_currency_id(integer, foreign key currencies, not null)
     --|--|--|--
     1|ER001|1|2
     2|ER002|2|1
     3|ER003|3|1
* table "exchange_rate_movements"
  * description: store movement rate of exchange rate list
  * id(integer, primary key, not null)|code(vchar, not null)|exchange_rate_id(integer, foreign key exchange_rates, not null)|rate(float, not null)|effective_date(date, not null)
    --|--|--|--|--
    1|ERM001|1|14321|2018-07-02
    2|ERM002|2|0.00007|2018-07-01
    3|ERM003|3|0.7824|2018-06-30
