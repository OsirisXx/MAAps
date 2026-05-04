# Implementation Plan: Update Checkout Fees

## Overview

This implementation plan updates the fee structure in the MAAPS e-commerce website to apply a delivery fee of ₱99 and add a new convenience fee of ₱99. The changes affect three primary functions in the single-page HTML application: `renderCart()`, `renderCheckoutSummary()`, and `placeOrder()`. All modifications occur within the existing `maaps-website.html` file.

## Tasks

- [x] 1. Update database schema to support convenience fee
  - Add `convenience_fee` column to the `orders` table in Supabase
  - Column type: DECIMAL(10,2) to store monetary values
  - Allow NULL values for backward compatibility with existing orders
  - _Requirements: 2.1, 2.4, 5.2_

- [x] 2. Update renderCart() function for fee calculation and display
  - [x] 2.1 Update fee calculation logic in renderCart()
    - Change shipping fee constant from 50 to 99 (deliveryFee)
    - Add new convenience fee constant of 99 (convenienceFee)
    - Update total calculation to: subtotal + deliveryFee + convenienceFee
    - Located around line 7667-7669 in maaps-website.html
    - _Requirements: 1.1, 2.1, 3.1, 3.4_
  
  - [x] 2.2 Update cart view HTML structure for fee display
    - Add HTML elements to display delivery fee as separate line item
    - Add HTML elements to display convenience fee as separate line item
    - Update the cart totals section to show: Subtotal, Delivery Fee, Convenience Fee, Total
    - Ensure all amounts are formatted with ₱ symbol and two decimal places
    - Located around line 7671-7672 in maaps-website.html
    - _Requirements: 1.2, 2.2, 4.1, 4.3, 4.4, 4.5_
  
  - [ ]* 2.3 Write unit tests for renderCart() fee calculations
    - Test total calculation with various subtotal amounts
    - Test that delivery fee is always ₱99.00
    - Test that convenience fee is always ₱99.00
    - Test decimal precision and rounding
    - _Requirements: 1.1, 2.1, 3.1_

- [x] 3. Update renderCheckoutSummary() function for fee calculation and display
  - [x] 3.1 Update fee calculation logic in renderCheckoutSummary()
    - Change shipping fee constant from 50 to 99 (deliveryFee)
    - Add new convenience fee constant of 99 (convenienceFee)
    - Update total calculation to: subtotal + deliveryFee + convenienceFee
    - Located around line 7685-7687 in maaps-website.html
    - _Requirements: 1.3, 2.3, 3.2, 3.4_
  
  - [x] 3.2 Update checkout summary HTML to display both fees
    - Add convenience fee line item between shipping fee and total
    - Update delivery fee label to show "Delivery Fee" or "Shipping Fee"
    - Add convenience fee label as "Convenience Fee"
    - Ensure all amounts are formatted with ₱ symbol and two decimal places
    - Located around line 7700-7708 in maaps-website.html
    - _Requirements: 2.3, 4.2, 4.3, 4.4, 4.5_
  
  - [ ]* 3.3 Write unit tests for renderCheckoutSummary() fee calculations
    - Test total calculation matches renderCart() calculations
    - Test fee display formatting
    - Test that both fees are shown as separate line items
    - _Requirements: 1.3, 2.3, 3.2_

- [x] 4. Checkpoint - Verify cart and checkout display changes
  - Ensure all tests pass, ask the user if questions arise.

- [x] 5. Update placeOrder() function for fee calculation and order data
  - [x] 5.1 Update fee calculation logic in placeOrder()
    - Change shippingFee constant from 50 to 99 (deliveryFee)
    - Add new convenienceFee constant of 99
    - Update totalAmount calculation to: subtotal + deliveryFee + convenienceFee
    - Located around line 7719-7721 in maaps-website.html
    - _Requirements: 1.4, 2.4, 3.4, 5.3_
  
  - [x] 5.2 Update order object structure to include convenience fee
    - Add convenience_fee field to the order object with value of convenienceFee
    - Ensure shipping_fee field uses the updated deliveryFee value (99)
    - Verify total_amount calculation includes both fees
    - Located around line 7723-7745 in maaps-website.html
    - _Requirements: 2.4, 5.1, 5.2, 5.3, 5.4_
  
  - [x] 5.3 Update Supabase insert to include convenience_fee field
    - Add convenience_fee field to the Supabase insert operation
    - Ensure the field maps to order.convenience_fee
    - Located around line 7753-7768 in maaps-website.html
    - _Requirements: 2.4, 5.2_
  
  - [ ]* 5.4 Write unit tests for placeOrder() order object creation
    - Test that order object includes convenience_fee field
    - Test that shipping_fee has updated value of 99
    - Test that total_amount equals subtotal + 99 + 99
    - Test order object structure matches expected format
    - _Requirements: 5.1, 5.2, 5.3, 5.4_

- [x] 6. Checkpoint - Verify order placement and data storage
  - Ensure all tests pass, ask the user if questions arise.

- [ ]* 7. Integration testing
  - [ ]* 7.1 Test complete cart-to-checkout flow
    - Add items to cart and verify fee calculations
    - Proceed to checkout and verify fees match cart totals
    - Complete order placement and verify order record
    - Test with various subtotal amounts (zero, small, large, decimal)
    - _Requirements: 1.1, 1.2, 1.3, 2.1, 2.2, 2.3, 3.1, 3.2_
  
  - [ ]* 7.2 Test edge cases
    - Test with empty cart (subtotal ₱0)
    - Test with very large subtotals (₱10,000+)
    - Test with decimal subtotals (e.g., ₱123.45)
    - Test with single item vs multiple items
    - Verify floating-point precision handling
    - _Requirements: 3.4, 4.5_
  
  - [ ]* 7.3 Test backward compatibility
    - Verify existing orders without convenience_fee display correctly
    - Verify order history shows old orders properly
    - Test that NULL convenience_fee values are handled gracefully
    - _Requirements: 5.2_

- [x] 8. Final checkpoint - Complete verification
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- All monetary values must be formatted with ₱ symbol and two decimal places
- Fee constants should be defined at the beginning of each function for clarity
- The database migration (task 1) should be completed before deploying code changes
- All changes are localized to the `maaps-website.html` file except the database schema update
- Existing orders without convenience_fee will have NULL values, which is acceptable
- Variable naming: use camelCase in JavaScript (deliveryFee, convenienceFee), snake_case in database (convenience_fee, shipping_fee)
