# SCRuB

SCRuB (gem name scrubdeku) is a Ruby gem to ease integration with the SellerCloud platform by providing a simple wrapper around the SellerCloud SOAP API.

To get started, require the gem 'SCRuB' in your project.

````
require 'SCRuB'
````

To create a new SellerCloud Client, create a new Scrub::SCClient object, passing it the SellerCloud address, username, and password.

````
scclient = Scrub::SCClient.new("http://tt.ws.sellercloud.com", "your.email@yourcompany.com", "hunter2")
````

Currently implements the following methods in SCClient:

````generalRaw```` and ````inventoryRaw```` are used to make direct calls to the SellerCloud API, either internally (most methods call ther appropriate raw method) or if there is a needed method that hasn't been implemented yet.  ````scclient.generalRaw(:api_call, {messageString => messageVar})````

````order_data(orderNumber)```` returns a hash of the complete API response for a given integer order number.

```getWarehouseInventory(warehouseid, page)```` returns per-page results for the SKUs in a given warehouse.

````getWarehouseInventoryList(warehouseid)```` returns the array of all item SKUs in a given warehouse identified by warehouseid.

````getAllWarehouseSkuList(warehouseArray)```` returns the list of all SKUs in the given warehouses.

````getSkuInventoryAllWarehouses(sku)```` returns hash of warehouse inventory data for sku

````getAllWarehousesInventoryTable(skuTable, threads)```` returns a hash of inventory data for all skus in array skuTable, using ````threads```` workers to make it somewhat faster.

````getInventoryByWarehouse(warehouse, sku)```` singular version of ````getSkuInventoryAllWarehouses````

````getProductNameFromSku(sku)```` does exactly what it says on the tin

