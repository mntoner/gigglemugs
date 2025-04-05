-- MYSQL Schema
-- These new database tables to be acompanied by a new app called 'Product Management'.
-- The app will be used for ordering and receiving stock, managing suppliers, buy items, deliveries, invoices, categories, reporting, etc.


-- Supercategories. USED ON TILLS. Level 1: Food, Drink
DROP TABLE IF EXISTS supercategory;
CREATE TABLE supercategory (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT
);

-- Categories. USED ON TILLS. Level 2: DRINK: Spirit, Wine, Draught Beer, etc. FOOD: Starters & Nibbles, Mains Courses, Light Bites & Sandwiches, Puddings & Cheese,etc 
DROP TABLE IF EXISTS category;
CREATE TABLE category (
    id INT PRIMARY KEY AUTO_INCREMENT,
    supercategory_id INT NOT NULL,
    name VARCHAR(50) NOT NULL,
    description TEXT,
    buy_size_id INT, -- REVIEW IF NEEDED?
    count_size_id INT, -- REVIEW IF NEEDED?
    code VARCHAR(10) UNIQUE, -- legacy code
    FOREIGN KEY (supercategory_id) REFERENCES supercategory(id)
);

-- Subcategories. USED ON TILLS. Level 3: DRINK: Vodka, Gin, Rum, etc. FOOD: include: Starters, Mains, Light, Puddings, etc
DROP TABLE IF EXISTS subcategory;
CREATE TABLE subcategory (
    id INT PRIMARY KEY AUTO_INCREMENT,
    category_id INT NOT NULL,
    name VARCHAR(50) NOT NULL,
    description TEXT,
    buy_size_id INT, -- REVIEW IF NEEDED?
    count_size_id INT, -- REVIEW IF NEEDED?
    FOREIGN KEY (category_id) REFERENCES category(id)
);

-- Measurement Units
DROP TABLE IF EXISTS unit;
CREATE TABLE unit (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL UNIQUE,
    abbreviation VARCHAR(10)
);
-- Insert common units of measurement for food & drink items
INSERT INTO unit (name, abbreviation) VALUES ('Gram', 'g');
INSERT INTO unit (name, abbreviation) VALUES ('Kilogram', 'kg');
INSERT INTO unit (name, abbreviation) VALUES ('Milliliter', 'ml');
INSERT INTO unit (name, abbreviation) VALUES ('Centiliter', 'cl');
INSERT INTO unit (name, abbreviation) VALUES ('Liter', 'l');
INSERT INTO unit (name, abbreviation) VALUES ('Gallon', 'gal');
INSERT INTO unit (name, abbreviation) VALUES ('Pint', 'pt');
INSERT INTO unit (name, abbreviation) VALUES ('Half Pint', 'half pt');
INSERT INTO unit (name, abbreviation) VALUES ('Bottle', 'btl');

-- Unit Conversions
CREATE TABLE unit_conversion (
    from_unit_id INT NOT NULL,
    to_unit_id INT NOT NULL,
    conversion_factor DECIMAL(10,4) NOT NULL,
    PRIMARY KEY (from_unit_id, to_unit_id),
    FOREIGN KEY (from_unit_id) REFERENCES unit(id),
    FOREIGN KEY (to_unit_id) REFERENCES unit(id)
);

-- wastage types
DROP TABLE IF EXISTS wastage_type;
CREATE TABLE wastage_type (
    id INT PRIMARY KEY AUTO_INCREMENT,
    type VARCHAR(50) NOT NULL UNIQUE,
    supercategory_id INT NOT NULL,
    FOREIGN KEY (supercategory_id) REFERENCES supercategory(id)
);

-- Purchase Package Sizes
DROP TABLE IF EXISTS buy_size;
CREATE TABLE buy_size (
    id INT PRIMARY KEY AUTO_INCREMENT,
    size DECIMAL(10,2) NOT NULL DEFAULT 0,
    unit_id INT NOT NULL DEFAULT 1, -- defaults to grams
    description VARCHAR(255),
    FOREIGN KEY (unit_id) REFERENCES unit(id)
);

-- Stocktake Count Sizes
DROP TABLE IF EXISTS count_size;
CREATE TABLE count_size (
    id INT PRIMARY KEY AUTO_INCREMENT,
    size DECIMAL(10,2) NOT NULL DEFAULT 0,
    unit_id INT NOT NULL DEFAULT 1, -- defaults to grams
    subcategory_id INT, -- REVIEW!!
    description VARCHAR(255),
    FOREIGN KEY (unit_id) REFERENCES unit(id)
);

-- Suppliers
DROP TABLE IF EXISTS supplier;
CREATE TABLE supplier (
    id INT PRIMARY KEY AUTO_INCREMENT,
    --su_code VARCHAR(10) UNIQUE, -- legacy supplier code -- NOT NEEDED
    su_d365 VARCHAR(50) UNIQUE, -- current supplier code D365
    local_supplier TINYINT(1) DEFAULT 0, -- 0 = no, 1 = yes. (1 has agreed prices)
    alcohol_supplier_awrs_id VARCHAR(255), -- null = not an alcohol supplier, not null = alcohol supplier with AWRS
    name VARCHAR(100) NOT NULL,
    contact_name VARCHAR(100),
    address TEXT,
    postcode VARCHAR(10),
    phone VARCHAR(25),
    email VARCHAR(100),
    supplier_json JSON, -- includes fields: navision code, can_order, etc. ADD SU_CODE TO JSON. ADD AWRS
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP
);

-- NEW TABLE BUY_ITEM_SUPPLIER
DROP TABLE IF EXISTS buy_item_supplier;
CREATE TABLE buy_item_supplier (
    id INT PRIMARY KEY AUTO_INCREMENT,
    buy_item_id INT NOT NULL, -- may be items from different suppliers for the same buy_item
    supplier_id INT NOT NULL,
    supplier_product_code VARCHAR(255) NOT NULL, -- product code provided by supplier. 
    latest_buy_price  DECIMAL(10,2) NOT NULL, -- price of the item from the supplier
    last_ordered DATE, -- date the of the most recent order
    default_buy_size_id INT NOT NULL, -- default buy size for the supplier
    default_count_size_id INT, -- default count size for the supplier -- REVIEW IF NEEDED?
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (buy_item_id) REFERENCES buy_item(id),
    FOREIGN KEY (supplier_id) REFERENCES supplier(id),
    FOREIGN KEY (default_buy_size_id) REFERENCES buy_size(id),
    FOREIGN KEY (default_count_size_id) REFERENCES count_size(id),
    UNIQUE KEY buy_item_supplier_unique (buy_item_id, supplier_id, supplier_product_code),
    INDEX supplier_product_code_index (supplier_product_code)
);

-- SUPPLIER_LOCATION
-- this table will list the locations where the supplier can deliver
-- this table will be used to filter suppliers by location in the Product Management app
DROP TABLE IF EXISTS supplier_location;
CREATE TABLE supplier_location (
    id INT PRIMARY KEY AUTO_INCREMENT,
    supplier_id INT NOT NULL,
    location_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (supplier_id) REFERENCES supplier(id)
);

-- NEW TABLE SUPPLIER_LOCATION - availability of supplier at location - possibly json

-- Purchasable Products. (Replaces the tables: Starchef & StockHo)
-- Contains all products that can be purchased from suppliers, both food and drink. New items are added when a new product is purchased for the first time.
-- This table represents the ingrdients that are used in Recipe Manager to build sell_items.
-- This is not to be confused with the inventory table which contains the real-time stock level for each buy_item by location.
DROP TABLE IF EXISTS buy_item;
CREATE TABLE buy_item (
    id INT PRIMARY KEY AUTO_INCREMENT, -- this will replace current ST_code / stock_code in use for wet stock
    guid VARCHAR(255) UNIQUE, -- Format E.G. '6f64a511-c99c-4ba1-8233-0e0c0fb274b4'. This is the guid (globally unique identifier) of the buy_item.
    --supplier_product_code VARCHAR(255) NOT NULL, -- product code provided by supplier. 
    --supplier_id INT NOT NULL, -- REMOVE FOR GENERIC PRODUCTS. BUY ITEMS ARE NOT SUPPLIER SPECIFIC. -- PREFERED SUPPLIER
    preferred_buy_item_supplier_id INT, 
    name VARCHAR(255) NOT NULL,
    description TEXT,
    category_id INT NOT NULL,
    subcategory_id INT,
    -- buy_size_id INT NOT NULL, -- this is the size of the item that can be purchased from the supplier. E.G. 11GAL, 12GAL, 100ML, 70CL, etc.
    -- count_size_id INT, -- stocktake count size -- DO PUBS HAVE DIFFERENT COUNT SIZES FOR THE SAME PRODUCT? NO!!! IMPLICIT IN SUBCATEGORY_ID. CAN REMOVE THIS.
    -- current_cost DECIMAL(10,2), -- current cost of the item. Updated on new deliveries. IS THIS NEEDED?? NO!!!!
    ingredient_json JSON, -- Starchef specific but may be used for wet items
    nutrition_json JSON, -- Starchef specific but may be used for wet items
    intolerances_json JSON, -- Starchef specific but may be used for wet items
    unavailable TINYINT(1) DEFAULT 0, -- 0 = available, 1 = unavailable. Unavailable items cant be used in Recipe Manager to create sell_items.
    sell_item_required TINYINT(1) DEFAULT 0, -- 0 = unprocessed, 1 = yes, 2 = no. Only applicable to buy_items with categories listed in sale_item_template table.
    sell_item_json JSON, -- contains the till button, recipe, etc. Used to create sell_items in Recipe Manager.
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,
    --FOREIGN KEY (supplier_id) REFERENCES supplier(id),
    FOREIGN KEY (category_id) REFERENCES category(id),
    FOREIGN KEY (subcategory_id) REFERENCES subcategory(id),
    FOREIGN KEY (buy_size_id) REFERENCES buy_size(id),
    --UNIQUE KEY supplier_product_unique (supplier_id, supplier_product_code),
    --INDEX supplier_product_code_index (supplier_product_code),
    INDEX guid_index (guid)
);

-- Sellable Items (replaces Recipes table)
-- This is the main table used by Recipe Manager app which allows users to build sellable items from buy items as ingredients.
DROP TABLE IF EXISTS sale_item;
CREATE TABLE sale_item (
    id INT PRIMARY KEY AUTO_INCREMENT,
    location_id INT NOT NULL, -- 9200 used for non-location specific items
    title VARCHAR(255) NOT NULL, -- name of the item
    header VARCHAR(255), -- used on menus
    description VARCHAR(255), -- used on menus
    button VARCHAR(30), -- till button text
    receipt VARCHAR(100), -- receipt text
    category_id INT NOT NULL, -- also known as 'usage' for food items
    subcategory_id INT,
    north_group_price DECIMAL(10,2),
    north_gp INT, 
    south_group_price DECIMAL(10,2),
    south_gp INT, 
    cost DECIMAL(10,2), 
    detail_json JSON, -- contains compiled info for sale items. Incl. cost, weight, notional price and notional GP, nutrition incl. kCal and allergens incl. gluten, lactose, nuts, etc
    menu_item_json JSON, -- info used in online and printed menus
    recipe_json JSON, -- contains additional details (some are for food based items only): haccp, method, serve, gfa_id, num portions, cooking temps, smaller portion ID, tech approval comment, etc
    ingredients_json JSON, -- contains ingredients (from buy_item table) and quantities. App login handles orphaning of ingredients. Includes the buy_item.id, guid, supplier_product_code and other details for each ingredient used in the sale item
    pricing_json JSON, -- contains group pricing, pub pricing and potentially other pricing info
    tags_json JSON,
    media_json JSON, -- images and video fielnames stored on AWS S3
    executive_approval_level INT, -- 0: not approved, 5: approved (only used initially on food items)
    executive_approval_by INT, -- user_id of the executice chef who approved the item
    executive_approval_date DATE, 
    technical_approval DATETIME, -- date and time of technical approval. null value means does not have technical approval
    technical_approval_by INT, -- user_id of the technical team member who approved the item
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,
    FOREIGN KEY (sale_item_template_id) REFERENCES sale_item_template(id),
    FOREIGN KEY (category_id) REFERENCES category(id),
    FOREIGN KEY (subcategory_id) REFERENCES subcategory(id),
    FOREIGN KEY (location_id) REFERENCES controller_core.location_core(id), -- existing table in controller_core schema
    FOREIGN KEY (executive_approval_by) REFERENCES controller_core.users(id), -- existing table in controller_core schema
    FOREIGN KEY (technical_approval_by) REFERENCES controller_core.users(id), -- existing table in controller_core schema
    INDEX location_category_idx (location_id, category_id),
    INDEX title_index (title),
    INDEX deleted_at_idx (deleted_at)
);

-- Sales Item Templates
-- This tables is used to create new sale_items when new a buy_item of certain categories are delivered for the first time.
-- E.G. If a new product is purchased for category 'Beer', a new sale_item record is can be created for 'Pint' and 'Half Pint' sizes.
-- Only certail categories are listed in sale_item_template so not all buy_items can be converted to sale_items.
-- PROCESS:
-- 1. A new buy_item record is created in Product Management app with its sell_item_required field set to 0.
-- 2. A delivery of the same product is processed and the system checks the sell_item_required field. 
-- 3. If the field is zero and the category is listed in sale_item_template, the user is asked to confirm the creation of the new sale_item.
-- 4. If the user confirms, the sell_item_required field is set to 1 and the new sale_item is created. (recipe manager API required)
-- 5. If the user does not confirm, the sell_item_required field is set to 2, so the user will not be asked again.

DROP TABLE IF EXISTS sale_item_template;
CREATE TABLE sale_item_template (
    id INT PRIMARY KEY AUTO_INCREMENT,
    category_id INT NOT NULL,
    name VARCHAR(100) NOT NULL, -- E.G., Half Pint, Pint, Glass, Bottle, etc. Used by Recipe Manager to build the sell_item.
    size DECIMAL(10,2) NOT NULL, -- the quantity & unit is used in Recipe Manager to build the sell_item.
    unit_id INT NOT NULL, 
    active TINYINT(1) DEFAULT 1, -- 0 = inactive, 1 = active. Inactive items won't be used to create sell_items.
    FOREIGN KEY (category_id) REFERENCES category(id),
    FOREIGN KEY (unit_id) REFERENCES unit(id)
);

--------------- REVISIT --------------
-- Stock Period
-- 1 row per period
-- holds future and past periods and the stocktake date for each period
-- DROP TABLE IF EXISTS stock_period;
-- CREATE TABLE stock_period (
--     id INT PRIMARY KEY AUTO_INCREMENT,
--     stock_period_number INT UNIQUE,
--     period_start_date DATE, ------------- ??
--     period_end_date DATE,
--     weeks INT, -- ?? weeks in this period
--     week_number INT, -- ??
--     year INT,
--     stocktake_date DATE,
--     comment TEXT
-- );

-- Financial Period
-- 1 row per week
-- holds future and past periods
DROP TABLE IF EXISTS financial_period;
CREATE TABLE financial_period (
    id INT PRIMARY KEY AUTO_INCREMENT,
    financial_period_number INT,
    stock_period_number INT,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    week_number INT,
    year INT
);

-- Purchase Order table is used to order new stock
-- Initially used only for wet stock ordering. Dry stock is currently ordered on third party system
DROP TABLE IF EXISTS purchase_order;
CREATE TABLE purchase_order (
    id INT PRIMARY KEY AUTO_INCREMENT,
    supplier_id INT NOT NULL,
    location_id INT NOT NULL,
    order_date DATE NOT NULL,
    expected_delivery_date DATE,
    detail_json JSON, -- detail lines includes buy_item_id if it exists.
    status ENUM('pending', 'delivered', 'cancelled') DEFAULT 'pending', -- app logic handles the status and creates the delivery record when the invoice is processed
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (supplier_id) REFERENCES supplier(id)
    FOREIGN KEY (location_id) REFERENCES controller_core.location_core(id) -- existing table in controller_core schema
);

-- Delivery Holding
-- holds auto imported invoices. This table will be used to hold the invoice data until it is approved and then moved to the delivery table.
DROP TABLE IF EXISTS delivery_holding;
CREATE TABLE delivery_holding (
    id INT PRIMARY KEY AUTO_INCREMENT,
    location_id INT,
    order_id INT, -- order id may appear on the invoice
    invoice_number VARCHAR(100) UNIQUE,
    delivery_date DATE NOT NULL,
    week_number INT,
    period_number INT,
    detail_json JSON, -- detail lines includes the buy_item_id. The supplier_product_code from the invoice is used to search the buy_item table to get the buy_item_id. If this is a new product, a buy item record is created before the delivery_holding record is finalised.
    net_amount DECIMAL(10,2) NOT NULL,
    gross_amount DECIMAL(10,2) NOT NULL,
    vat_amount DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES purchase_order(id),
    FOREIGN KEY (location_id) REFERENCES controller_core.location_core(id) -- existing table in controller_core schema
);

-- Deliveries
-- Delivery records are created when a user accepts an invoice listed in delivery_holding table.
-- Records can also be created manually in Product Management app.
-- Records are finalised in Invoice Management section of Product Management app. 
DROP TABLE IF EXISTS delivery;
CREATE TABLE delivery (
    id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT,
    supplier_id INT, -- needed in cases where there is no order_id.
    holding_id INT, -- used to link the delivery holding record for auto imported invoices. null for non-imported invoices.    
    location_id INT,
    audit_number VARCHAR(50) UNIQUE, -- legacy ID
    invoice_number VARCHAR(100) NOT NULL, -- the original invoice number stored in case of a change to the invoice number.
    invoice_number_amended VARCHAR(100) NOT NULL,
    invoice_date DATE NOT NULL, -- the original invoice date stored in case of a change to the invoice date.
    invoice_date_amended DATE NOT NULL,
    week_number INT,
    stock_period_number INT,
    net_amount DECIMAL(10,2) NOT NULL,
    net_amount_amended DECIMAL(10,2),
    gross_amount DECIMAL(10,2) NOT NULL,
    gross_amount_amended DECIMAL(10,2),
    vat_amount DECIMAL(10,2) NOT NULL,
    vat_amount_amended DECIMAL(10,2),
    status ENUM('delivered', 'marked for export', 'invoiced') DEFAULT 'delivered', -- app logic handles the status and creates the delivery record when the invoice is processed
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES purchase_order(id),
    FOREIGN KEY (location_id) REFERENCES controller_core.location_core(id), -- existing table in controller_core schema
    FOREIGN KEY (holding_id) REFERENCES delivery_holding(id),
    FOREIGN KEY (stock_period_number) REFERENCES financial_period(stock_period_number),
    FOREIGN KEY (supplier_id) REFERENCES supplier(id),
    INDEX delivery_date_idx (invoice_date),
    INDEX location_date_idx (location_id, invoice_date)
);

-- delivery detail
DROP TABLE IF EXISTS delivery_detail;
CREATE TABLE delivery_detail (
    id INT PRIMARY KEY AUTO_INCREMENT,
    delivery_id INT,
    buy_item_id INT,
    unit_cost DECIMAL(10,2),
    unit_cost_amended DECIMAL(10,2),
    quantity INT NOT NULL,
    quantity_amended INT,
    net_amount DECIMAL(10,2) NOT NULL,
    net_amount_amended DECIMAL(10,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (delivery_id) REFERENCES delivery(id),
    FOREIGN KEY (buy_item_id) REFERENCES buy_item(id)
);

-- credit notes
DROP TABLE IF EXISTS credit_note;
CREATE TABLE credit_note (
    id INT PRIMARY KEY AUTO_INCREMENT,
    delivery_id INT,
    credit_note_date DATE NOT NULL,
    net_amount DECIMAL(10,2) NOT NULL,
    gross_amount DECIMAL(10,2) NOT NULL,
    vat_amount DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (delivery_id) REFERENCES delivery(id)
);

-- Stocktake
DROP TABLE IF EXISTS stocktake;
CREATE TABLE stocktake (
    id INT PRIMARY KEY AUTO_INCREMENT,
    location_id INT,
    stocktake_date DATE NOT NULL,
    stock_period_number INT,
    stocktake_value DECIMAL(10,2) NOT NULL,
    comment TEXT,
    completed_by INT, -- user_id of the user who completed the stocktake
    FOREIGN KEY (location_id) REFERENCES controller_core.location_core(id),
    FOREIGN KEY (completed_by) REFERENCES controller_core.users(id),
    FOREIGN KEY (stock_period_number) REFERENCES financial_period(stock_period_number),
    INDEX location_date_idx (location_id, stocktake_date)
);

-- stocktake detail
DROP TABLE IF EXISTS stocktake_detail;
CREATE TABLE stocktake_detail (
    id INT PRIMARY KEY AUTO_INCREMENT,
    stocktake_id INT,
    buy_item_id INT,
    quantity DECIMAL(10,2) NOT NULL, -- number of units counted
    unit_cost DECIMAL(10,2) NOT NULL, -- count size unit cost (count size ID is in buy_item table)
    total_cost DECIMAL(10,2) NOT NULL, -- total cost of all units counted
    sell_price DECIMAL(10,2) NOT NULL, -- sell price of 1 measure - legacy field - IS THIS NEEDED?
    measures DECIMAL(10,2) NOT NULL, -- number of measures in 1 unit of count size - legacy field - IS THIS NEEDED?
    quantity_1 DECIMAL(10,2) NOT NULL, -- quantity in location 1
    quantity_2 DECIMAL(10,2) NOT NULL, -- quantity in location 2
    quantity_3 DECIMAL(10,2) NOT NULL, -- quantity in location 3
    quantity_4 DECIMAL(10,2) NOT NULL, -- quantity in location 4
    quantity_5 DECIMAL(10,2) NOT NULL, -- quantity in location 5
    quantity_6 DECIMAL(10,2) NOT NULL, -- quantity in location 6
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (stocktake_id) REFERENCES stocktake(id),
    FOREIGN KEY (buy_item_id) REFERENCES buy_item(id)
);

-- Inventory
-- real-time inventory for each buy_item by location. 
-- Updated on delivery, stocktake, sale_item_detail and possibly wastage 
CREATE TABLE inventory (
    id INT PRIMARY KEY AUTO_INCREMENT,
    location_id INT NOT NULL,
    buy_item_id INT NOT NULL,
    quantity DECIMAL(10,2) NOT NULL,
    update_source VARCHAR(50), -- 'STOCKTAKE', 'DELIVERY', 'SALE_ITEM_DETAIL', 'WASTAGE', etc
    last_stocktake_date DATE,
    last_delivery_date DATE,
    last_sale_item_detail_date DATE,
    last_wastage_detail_date DATE, -- only needed if we are recording wastage by buy item
    last_updated TIMESTAMP,
    FOREIGN KEY (location_id) REFERENCES controller_core.location_core(id),
    FOREIGN KEY (buy_item_id) REFERENCES buy_item(id),
    UNIQUE KEY location_item_unique (location_id, buy_item_id) -- only one 
);

-- inventory audit
-- records daily changes to inventory by location and buy item
-- updated by trigger from inventory table
CREATE TABLE inventory_audit (
    id INT PRIMARY KEY AUTO_INCREMENT,
    buy_item_id INT NOT NULL,
    location_id INT NOT NULL,
    old_quantity DECIMAL(10,2),
    new_quantity DECIMAL(10,2),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    changed_by INT NOT NULL,
    source VARCHAR(50)  -- 'STOCKTAKE', 'DELIVERY', 'WASTAGE', etc
);
CREATE TRIGGER inventory_audit_trigger
AFTER UPDATE ON inventory
FOR EACH ROW 
INSERT INTO inventory_audit (buy_item_id, location_id, old_quantity, new_quantity, source)
VALUES (OLD.buy_item_id, OLD.location_id, OLD.quantity, NEW.quantity, NEW.update_source);

-- sale item detail
-- records daily sales of sale items by location
-- Cash Controller process acquires sales from till data and creates a sale item detail record.
DROP TABLE IF EXISTS sale_item_detail;
CREATE TABLE sale_item_detail (
    id INT PRIMARY KEY AUTO_INCREMENT,
    location_id INT,
    date DATE NOT NULL,
    sale_item_id INT,
    quantity DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (sale_item_id) REFERENCES sale_item(id),
    FOREIGN KEY (location_id) REFERENCES controller_core.location_core(id),
    INDEX location_date_idx (location_id, date)
);

-- wastage
-- records daily wastage by location
DROP TABLE IF EXISTS wastage;
CREATE TABLE wastage (
    id INT PRIMARY KEY AUTO_INCREMENT,
    location_id INT,
    date DATE NOT NULL,
    week_number INT,
    stock_period_number INT,
    year INT,
    total_wastage DECIMAL(10,2),
    drink_wastage DECIMAL(10,2),
    food_wastage DECIMAL(10,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (location_id) REFERENCES controller_core.location_core(id),
    FOREIGN KEY (stock_period_number) REFERENCES financial_period(stock_period_number),
    INDEX location_date_idx (location_id, date),
    INDEX location_stock_period_idx (location_id, stock_period_number)
);

-- wastage detail
-- records daily wastage by location and wastage type
-- Wastage Manager process acquires voids from till data and creates a wastage detail record.
DROP TABLE IF EXISTS wastage_detail;
CREATE TABLE wastage_detail (
    id INT PRIMARY KEY AUTO_INCREMENT,
    location_id INT,
    date DATE NOT NULL,
    week_number INT,
    stock_period_number INT,   
    wastage_type_id INT,
    buy_item_id INT, -- SHOULD WE RECORD WASTAGE BY BUY_ITEM ??
    quantity DECIMAL(10,2) NOT NULL, -- only needed if we are recording wastage by buy item -- this is the quantity of the buy_item not grammage!
    value DECIMAL(10,2) NOT NULL, -- cost of the wastage (not sale price)
    FOREIGN KEY (location_id) REFERENCES controller_core.location_core(id),
    FOREIGN KEY (wastage_type_id) REFERENCES wastage_type(id),
    FOREIGN KEY (stock_period_number) REFERENCES financial_period(stock_period_number),
);

-- Cash Controller
-- single table replaces various tables in legacy CashLive database
DROP TABLE IF EXISTS cash_controller;
CREATE TABLE cash_controller (
    id INT PRIMARY KEY AUTO_INCREMENT,
    location_id INT,
    date DATE NOT NULL,
    financial_period_number INT,
    stock_period_number INT,
    week_number INT,
    year INT,
    total_sales_gross DECIMAL(10,2),
    total_sales_net DECIMAL(10,2),
    total_sales_vat DECIMAL(10,2),
    total_sales_discount DECIMAL(10,2),
    total_sales_gross_less_discount DECIMAL(10,2),
    daily_sales_json JSON, -- contains daily sales by location and supercat -- compiled from: sale_item_detail table
    declare_figures_json JSON, -- imported and adjusted in Cash Controller app
    petty_cash_json JSON,
    voucher_json JSON,
    sevenrooms_json JSON,
    customer_account_json JSON,
    safe_json JSON, -- detail and summary of safe
    till_summary_json JSON, -- end of day summary incl variance & comments
    completed_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,
    FOREIGN KEY (location_id) REFERENCES controller_core.location_core(id),
    FOREIGN KEY (completed_by) REFERENCES controller_core.users(id),
    FOREIGN KEY (financial_period_number) REFERENCES financial_period(financial_period_number),
    FOREIGN KEY (stock_period_number) REFERENCES financial_period(stock_period_number),
    INDEX location_id_idx (location_id),
    INDEX financial_period_number_idx (financial_period_number),
    INDEX stock_period_number_idx (stock_period_number),
    INDEX location_date_idx (location_id, date),
    INDEX location_financial_period_idx (location_id,financial_period_number),
    INDEX location_stock_period_idx (location_id,stock_period_number)
);


-- Materialized View for Stock Consumption
-- Records daily consumption of stock by location
CREATE OR REPLACE VIEW stock_consumption_mv AS
WITH daily_sales_consumption AS (
    -- Calculate consumption from sales
    SELECT 
        sid.location_id,
        sid.date,
        bi.id as buy_item_id,
        bi.name as buy_item_name,
        bi.supplier_product_code,
        c.name as category_name,
        sc.name as subcategory_name,
        sup.name as supplier_name,
        CAST(
            JSON_EXTRACT(si.ingredients_json, 
                CONCAT('$.', bi.id, '.quantity')
            ) AS DECIMAL(10,2)
        ) * sid.quantity as quantity_consumed,
        bi.current_cost * (
            CAST(
                JSON_EXTRACT(si.ingredients_json, 
                    CONCAT('$.', bi.id, '.quantity')
                ) AS DECIMAL(10,2)
            ) * sid.quantity
        ) as cost_consumed
    FROM sale_item_detail sid
    JOIN sale_item si ON sid.sale_item_id = si.id
    JOIN buy_item bi ON JSON_CONTAINS_PATH(
        si.ingredients_json,
        'one',
        CONCAT('$.', bi.id)
    ) = 1
    JOIN category c ON bi.category_id = c.id
    LEFT JOIN subcategory sc ON bi.subcategory_id = sc.id
    JOIN supplier sup ON bi.supplier_id = sup.id
),
daily_wastage_consumption AS (
    -- Calculate consumption from wastage (if tracking by buy_item)
    SELECT 
        location_id,
        date,
        buy_item_id,
        quantity as quantity_consumed,
        value as cost_consumed
    FROM wastage_detail
    WHERE buy_item_id IS NOT NULL
)
SELECT 
    COALESCE(s.location_id, w.location_id) as location_id,
    COALESCE(s.date, w.date) as date,
    COALESCE(s.buy_item_id, w.buy_item_id) as buy_item_id,
    s.buy_item_name,
    s.supplier_product_code,
    s.category_name,
    s.subcategory_name,
    s.supplier_name,
    COALESCE(s.quantity_consumed, 0) as sales_quantity,
    COALESCE(s.cost_consumed, 0) as sales_cost,
    COALESCE(w.quantity_consumed, 0) as wastage_quantity,
    COALESCE(w.cost_consumed, 0) as wastage_cost,
    COALESCE(s.quantity_consumed, 0) + COALESCE(w.quantity_consumed, 0) as total_quantity_consumed,
    COALESCE(s.cost_consumed, 0) + COALESCE(w.cost_consumed, 0) as total_cost_consumed
FROM daily_sales_consumption s
FULL OUTER JOIN daily_wastage_consumption w 
    ON s.location_id = w.location_id 
    AND s.date = w.date 
    AND s.buy_item_id = w.buy_item_id;

CREATE INDEX stock_consumption_mv_location_date_idx ON stock_consumption_mv (location_id, date);
CREATE INDEX stock_consumption_mv_buy_item_idx ON stock_consumption_mv (buy_item_id);

-- example query
-- SELECT * FROM stock_consumption_mv 
-- WHERE location_id = 7021 
-- AND date BETWEEN '2024-01-01' AND '2024-01-31';






