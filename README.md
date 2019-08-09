# Ruby on Rails - Intermediate Ruby on Rails - Active Record - Project

## Setup

Clone the application and bundle install. Then, create, migrate, and seed the database.

## Intro

This app is a partially completed API that will power a warehouse fulfillment client application. We have already built the customer and products portions but need to add orders and a way to associate orders with products.

Here is a breakdown of the existing data model for the application:

**`Customer`**

| attribute  | type     |
| ---------- | -------- |
| id         | integer  |
| email      | string   |
| created_at | datetime |
| updated_at | datetime |

**`Product`**

| attribute  | type     |
| ---------- | -------- |
| id         | integer  |
| name       | string   |
| cost_cents | integer  |
| inventory  | integer  |
| created_at | datetime |
| updated_at | datetime |

**`Order`**

| attribute   | type     |
| ----------- | -------- |
| id          | integer  |
| status      | string   |
| customer_id | integer  |
| created_at  | datetime |
| updated_at  | datetime |

**`OrderProduct`**

| attribute  | type     |
| ---------- | -------- |
| id         | integer  |
| order_id   | integer  |
| product_id | integer  |
| created_at | datetime |
| updated_at | datetime |

### Resources

Here is a breakdown of the existing resource API for the application.

| verb   | resource | route                                 | controller#action        | note                           |
| ------ | -------- | ------------------------------------- | ------------------------ | ------------------------------ |
| GET    | customer | /api/v1/customers                     | api/v1/customers#index   | list all customers             |
| POST   | customer | /api/v1/customers                     | api/v1/customers#create  | create a customer              |
| GET    | customer | /api/v1/customers/:id                 | api/v1/customers#show    | get a customer                 |
| PATCH  | customer | /api/v1/customers/:id                 | api/v1/customers#update  | update a customer              |
| PUT    | customer | /api/v1/customers/:id                 | api/v1/customers#update  | update a customer              |
| DELETE | customer | /api/v1/customers/:id                 | api/v1/customers#destroy | delete a customer              |
| GET    | order    | /api/v1/orders                        | api/v1/orders#index      | list all orders                |
| GET    | order    | /api/v1/customers/:customer_id/orders | api/v1/orders#index      | list all orders for a customer |
| POST   | order    | /api/v1/customers/:customer_id/orders | api/v1/orders#create     | create an order for a customer |
| GET    | order    | /api/v1/orders/:id                    | api/v1/orders#show       | get a specific order           |
| POST   | order    | /api/v1/orders/:id/ship               | api/v1/orders#ship       | ship a specific order          |
| GET    | product  | /api/v1/products                      | api/v1/products#index    | list all products              |
| GET    | product  | /api/v1/products/:id                  | api/v1/products#show     | get a specific product         |
| GET    | product  | /api/v1/orders/:order_id/products     | api/v1/products#index    | list all products for an order |
| POST   | product  | /api/v1/orders/:order_id/products     | api/v1/products#create   | add a product to an order      |

## Step One - Add and Utilize ActiveRecord Associations

We can use active record associations to simplify some of our queries and creation logic. We can do this by using assocations in our models that acknowledge the relationships in our data.

1. Add an association to Customer representing that it can have many associated Orders.
2. Add associations to OrderProduct representing that it belongs to both an Order and a Product.
3. Add an association to Product representing that it can have many associated OrderProducts.
4. Add an association to Product representing that it can have many associated Orders via the relationship with OrderProducts.
   - This is known as a `has many through` association; OrderProducts acts a join model between Orders and Products.
5. Add an association to Order to represent that it can have many associated OrderProducts.
6. Add an association to Order to represent that it can have many associated Products via the relationship with OrderProducts.
7. Add an association to Order to represent that it belongs to a Customer

## Step Two - Utilize ActiveRecord Associations

Notice the instance method `products` defined on Order. It queries the related OrderProducts and then uses those values to query Products. That is what a `has many through` does for us automatically. Named associations become instance methods so instead of keeping our own custom `products` method, delete it and rely on the association instead.

1. Remove the now unnecessary `products` instance method on Order.

Similar code is found in the products#index controller action. Instead of doing the full query, find the correct order based on Order id and use the assocation method to get the list of products

2. Replace OrderProducts query in products#index with simplified association method

products#create can be simplified by using association methods on `@order` to build an `OrderProduct` that already includes the `order_id`

3. Simplify OrderProduct instantiation by using association build

## Step Three - Add ActiveRecord Validations

`Customer`:

1. Validate that customer always has an email.

`Product`:

1. Validate that a product always has a `name`.
2. Validate that a product always has a `cost_cents` and that it is greater than 0.
3. Validate that a product always has an `inventory` and that its greater than or equal to 0

`Order`:

1. Validate that an order always has a `status` and it's value is either "pending" or "shipped"

## Step Four - Add Reusable Queries vis Scopes and Use EagerLoading to Improve Problem Queries

We need to convert the available products query into a scope so that it can be reused in several new features we are planning. Currently, it is manually written in the products#index controller action using a where and order clause:

```ruby
# app/controllers/api/v1/products_controller.rb
@products = Product.where("inventory > ?", 0).order(:cost)
```

1. Convert this query to a scope on products named `in_stock`.
2. Create another scope that provides the inverse information named `out_of_stock` that should list all products with `0` inventory ordered by `cost`.
3. Use the `in_stock` scope in the products#index controller action instead of the inline query we have now

Our customers#index controller action does a simple Customer.all query. It then iterates through each query to display the Customer orders as part of the customer resource. This is where the query becomes non performant, it hits the database multiple times (n + 1).

4. Use eagerloading on the `Customer.all` call to prevent "n + 1" database queries
