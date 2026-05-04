# Requirements Document

## Introduction

This document specifies the requirements for updating the checkout fee structure in the MAAPS e-commerce website. The client has requested changes to the delivery fee amount and the addition of a new convenience fee. Both fees will be set to ₱99 each. This update affects the cart totals display, checkout summary display, and order placement calculations.

## Glossary

- **Checkout_System**: The component responsible for calculating and displaying order totals, including subtotal, fees, and final total amount
- **Cart_View**: The shopping cart interface that displays items and calculates preliminary totals before checkout
- **Delivery_Fee**: The shipping charge applied to all orders for product delivery
- **Convenience_Fee**: A service charge applied to all orders for processing and handling
- **Subtotal**: The sum of all product prices multiplied by their quantities, before fees are applied
- **Total_Amount**: The final amount to be paid, calculated as Subtotal + Delivery_Fee + Convenience_Fee
- **Order_Record**: The data structure containing all order information including fees and total amount

## Requirements

### Requirement 1: Update Delivery Fee Amount

**User Story:** As a business owner, I want to update the delivery fee from ₱50 to ₱99, so that the fee reflects current delivery costs.

#### Acceptance Criteria

1. THE Checkout_System SHALL apply a delivery fee of ₱99.00 to all orders
2. WHEN calculating cart totals, THE Cart_View SHALL display the delivery fee as ₱99.00
3. WHEN displaying the checkout summary, THE Checkout_System SHALL show the delivery fee as ₱99.00
4. WHEN creating an order record, THE Checkout_System SHALL store the delivery fee value as 99

### Requirement 2: Add Convenience Fee

**User Story:** As a business owner, I want to add a convenience fee of ₱99 to all orders, so that processing and handling costs are covered.

#### Acceptance Criteria

1. THE Checkout_System SHALL apply a convenience fee of ₱99.00 to all orders
2. WHEN calculating cart totals, THE Cart_View SHALL include the convenience fee in the total amount
3. WHEN displaying the checkout summary, THE Checkout_System SHALL show the convenience fee as a separate line item with the amount ₱99.00
4. WHEN creating an order record, THE Checkout_System SHALL store the convenience fee value as 99

### Requirement 3: Calculate Total Amount with Both Fees

**User Story:** As a customer, I want to see the correct total amount including both delivery and convenience fees, so that I know the exact amount I will pay.

#### Acceptance Criteria

1. THE Checkout_System SHALL calculate the total amount as Subtotal + Delivery_Fee + Convenience_Fee
2. WHEN displaying cart totals, THE Cart_View SHALL show the total amount including both fees
3. WHEN displaying the checkout summary, THE Checkout_System SHALL show the total amount including both fees
4. FOR ALL orders with any subtotal value, THE Total_Amount SHALL equal the sum of Subtotal, Delivery_Fee (₱99), and Convenience_Fee (₱99)

### Requirement 4: Display Fee Breakdown

**User Story:** As a customer, I want to see a clear breakdown of all fees, so that I understand what charges are being applied to my order.

#### Acceptance Criteria

1. WHEN viewing the cart, THE Cart_View SHALL display the subtotal, delivery fee, convenience fee, and total amount as separate line items
2. WHEN viewing the checkout summary, THE Checkout_System SHALL display the subtotal, delivery fee, convenience fee, and total amount as separate line items
3. THE Checkout_System SHALL label the delivery fee as "Delivery Fee" or "Shipping Fee"
4. THE Checkout_System SHALL label the convenience fee as "Convenience Fee"
5. THE Checkout_System SHALL format all monetary amounts with the peso symbol (₱) and two decimal places

### Requirement 5: Store Fee Information in Order Records

**User Story:** As a business owner, I want fee information stored in order records, so that I can track revenue from different fee sources.

#### Acceptance Criteria

1. WHEN an order is placed, THE Checkout_System SHALL store the delivery fee amount in the order record
2. WHEN an order is placed, THE Checkout_System SHALL store the convenience fee amount in the order record
3. WHEN an order is placed, THE Checkout_System SHALL store the total amount including both fees in the order record
4. FOR ALL order records, THE stored total amount SHALL equal the sum of subtotal, delivery fee, and convenience fee
