# Description
foreign exchange rate for training with normalization database

# List
* [Step to build environment](#step-to-build-environment)
* [structure database](#structure-database)
* [API Guide](#api-guide)

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
    
# API Guide

## input daily exchange rate data
method `POST`

url `localhost:3000/exchange_rate_movements`

request header
```
content-type: application/json
```
request body
```
{
 "from_currency": "USD", 
 "to_currency": "GBP",
 "effective_date": "2018-07-05",
 "rate": "0.75709"
}
```
response body if success

```
{
 "message": "Exchange rate data success created"
}
```
response body if error

```
{
 "errors": {
   "from_currency": ["must not same with to currency"],
   "to_currency": ["must not same with from currency"]
 }
}
```

## get list exchange rate data to be tracked
method `GET`

url `localhost:3000/exchange_rate_movements/search`

request header
```
content-type: application/json
```
request body
```
{
 "from_currency": "USD", 
 "to_currency": "GBP",
 "effective_date": "2018-07-05",
 "rate": "0.75709"
}
```
response body if success

```
{
 "results": [
  {
   "from_currency_id":748,
   "from_currency_code": "GBP",
   "to_currency_id": 747,
   "to_currency_code": "USD",
   "rate": "1.314233",
   "seven_day_avg": 1.316904
  },
  {
   "from_currency_id":894,
   "from_currency_code": "JPY",
   "to_currency_id": 747,
   "to_currency_code": "USD",
   "rate": "insuficient data",
   "seven_day_avg": null
  }
 ]
}
```
response body if error

```
{
 "errors": {
   "effective_date": ["must be date, can't be blank"]
 }
}
```

## add an exchange rate into list
method `POST`

url `localhost:3000/exchange_rates`

request header
```
content-type: application/json
```
request body
```
{
 "from_currency": "USD", 
 "to_currency": "GBP",
}
```
response body if success

```
{
 "message": "Exchange rate success created"
}
```
response body if error

```
{
 "errors": {
   "from_currency": ["must not same with to currency"],
   "to_currency": ["must not same with from currency"]
 }
}
```

## remove exchange rate from list
method `DELETE`

url `localhost:3000/exchange_rates`

request header
```
content-type: application/json
```
request body
```
{
 "from_currency": "USD", 
 "to_currency": "GBP",
}
```
response body if success

```
{
 "message": "Exchange rate success destroyed"
}
```
response body if error

```
{
 "errors": {
   "base": ["Exchange rate failed destroyed"],
 }
}
```
