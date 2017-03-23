require 'savon'
require 'thread'

class Array; def in_groups(num_groups)
  return [] if num_groups == 0
  slice_size = (self.size/Float(num_groups)).ceil
  groups = self.each_slice(slice_size).to_a
end; end
module Scrub
  class SCClient
    def initialize(server, username, password)
      @generalClient = self.createClient(server, "/scservice.asmx?WSDL", username, password)
      @inventoryClient = self.createClient(server, "/SCInventoryService.asmx?wsdl", username, password)
    end

    def createClient(server, location, username, password)
      return Savon.client(wsdl: "#{server}#{location}", soap_header: {'AuthHeader' => {:@xmlns => "http://api.sellercloud.com/", 'UserName' => username, 'Password' => password}}, env_namespace: :soap, pretty_print_xml: true)
    end

    def order_data(orderNumber)
      @generalClient.call(:orders_get_data, message: {'orderId' => orderNumber}).to_hash
    end

    def getWarehouseInventoryList(warehouseid)
      warehouseInventory = []
      page = 1
      pageLimitReached = false
      while pageLimitReached == false
        puts "Getting page... #{page.to_s}"
        response = self.getWarehouseInventory(warehouseid, page)
        if response.size > 0
          warehouseInventory += response
          page += 1
        elsif response.size == 0
          pageLimitReached = true
        end
      end
      puts "Compacting #{warehouseInventory.size} records..."
      return warehouseInventory.uniq
    end

    def getWarehouseInventory(warehouseid, page)
      begin
        response = @inventoryClient.call(:product_warehouse_inventory_get, message: {'WarehouseID' => warehouseid, 'pageNumber' => page}).to_hash[:product_warehouse_inventory_get_response][:product_warehouse_inventory_get_result][:string]
      rescue NoMethodError
        []
      rescue Net::OpenTimeout, Errno::ECONNRESET
        puts "Retrying..."
        retry
      end
    end

    def getAllWarehouseSkuList(warehouseArray)
      inventoryArray = []
      warehouseArray.each do |warehouse|
        inventoryArray = inventoryArray | self.getWarehouseInventoryList(warehouse)
      end
      return inventoryArray
    end

    def getSkuInventoryAllWarehouses(sku)
      begin
        response = self.generalRaw(:get_product_inventory_for_all_warehouses, {'ProductID' => sku})[:get_product_inventory_for_all_warehouses_response][:get_product_inventory_for_all_warehouses_result][:get_product_inventory_for_all_warehouses_response_type]
      rescue Net::OpenTimeout, Errno::ECONNRESET
        retry
      end
    end

    def getAllWarehousesInventoryTable(skuTable, threads)
      inventory = {}
      skus = skuTable.in_groups(threads)
      lock = Mutex.new
      threadList = []
      (0...threads).each do |i|
        threadList << Thread.new do
          threadTable = {}
          skus[i].each do |sku|
            puts "Getting data for #{sku}"
            response = self.getSkuInventoryAllWarehouses(sku)
            threadTable[sku] = response
            end
          lock.synchronize do
            inventory.merge!(threadTable)
          end
        end
      end
      threadList.each{|thr| thr.join}
      return inventory
    end

    def getInventoryByWarehouse(warehouse, sku)
      self.generalRaw(:get_inventory, {'ProductID' => sku, 'WarehouseID' => warehouse})
    end

    def getProductNameFromSku(sku)
      begin
        self.generalRaw(:get_product_info, {'id' => sku})[:get_product_info_response][:get_product_info_result][:product_name]
      rescue Net::OpenTimeout, Errno::ECONNRESET
        retry
      rescue NoMethodError
        ""
      end
    end

      #Testing/debugging calls
    def generalRaw(call, messageIn)
      @generalClient.call(call, message: messageIn).to_hash
    end

    def inventoryRaw(call, messageIn)
      @inventoryClient.call(call, message: messageIn).to_hash
    end

    def operations
      @generalClient.operations
    end

    def invOperations
      @inventoryClient.operations
    end
  end

  class Order
    def initialize(order_data)
      @data = order_data
    end

    def products
      productTable = {}

      orderData = @data[:orders_get_data_response][:orders_get_data_result][:order][:items][:order_item]
      if orderData.kind_of? Array
        productTable[orderData[:product_id]] = {"qty" => orderData[:qty], "description" => orderData[:display_name]}
      else
        orderData.each do |item|
          productTable[item[:product_id]] = {"qty" => item[:qty], "description" => item[:display_name]}
        end
      end
      return productTable
    end

    def kit_listing
      productTable = {}
      orderData = @data[:orders_get_data_response][:orders_get_data_result][:order][:items][:order_item]
      if orderData.kind_of? Array
        buildout = {}
        puts item[:bundle_items][:order_bundle_item]
        orderData[:bundle_items][:order_bundle_item].each do |bundleItem|
          buildout.merge!("#{bundleItem[:product_id]}" => {'qtyEach' => bundleItem[:qty], 'qtyTotal' => bundleItem[:total_qty]})
        end
        productTable[orderData[:product_id]] = {"qty" => orderData[:qty], "description" => orderData[:display_name], 'components' => buildout}
      else
        orderData.each do |item|
          buildout = {}
          puts item[:bundle_items][:order_bundle_item]
          item[:bundle_items][:order_bundle_item].each do |bundleItem|
            buildout.merge!("#{bundleItem[:product_id]}" => {'qtyEach' => bundleItem[:qty], 'qtyTotal' => bundleItem[:total_qty]})
          end
          productTable[item[:product_id]] = {"qty" => item[:qty], "description" => item[:display_name], 'components' => buildout}
        end
      end
      return productTable
    end
  end
end
