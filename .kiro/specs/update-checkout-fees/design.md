# Design Document: Update Checkout Fees

## Overview

This design document specifies the technical approach for updating the fee structure in the MAAPS e-commerce website. The implementation involves updating hardcoded fee values and adding a new convenience fee to the checkout system. The changes affect three primary functions in the single-page HTML application: `renderCart()`, `renderCheckoutSummary()`, and `placeOrder()`.

### Current State

The application currently applies a single shipping fee of ₱50.00 to all orders. This fee is hardcoded in three locations within the `maaps-website.html` file:
- Cart view totals calculation (line ~7668)
- Checkout summary display (line ~7686)
- Order placement data structure (line ~7720)

### Target State

The updated system will:
- Apply a delivery fee of ₱99.00 (updated from ₱50.00)
- Apply a new convenience fee of ₱99.00
- Calculate total as: Subtotal + Delivery Fee + Convenience Fee
- Display both fees as separate line items in cart and checkout views
- Store both fee values in order records

## Architecture

### Component Structure

The implementation follows the existing single-page application architecture with no structural changes required. All modifications occur within the existing `app` object's methods.

```
maaps-website.html
└── app object
    ├── renderCart()           → Update fee display and calculation
    ├── renderCheckoutSummary() → Update fee display and calculation
    └── placeOrder()           → Update order data structure
```

### Data Flow

```
User adds items to cart
    ↓
renderCart() calculates and displays:
    - Subtotal (sum of item prices × quantities)
    - Delivery Fee (₱99.00)
    - Convenience Fee (₱99.00)
    - Total (Subtotal + Delivery Fee + Convenience Fee)
    ↓
User proceeds to checkout
    ↓
renderCheckoutSummary() displays same breakdown
    ↓
User submits order
    ↓
placeOrder() stores all values in order record
```

## Components and Interfaces

### 1. Fee Constants

**Location**: Within each function that calculates fees

**Implementation Approach**: Define fee constants at the beginning of each function

```javascript
const deliveryFee = 99;
const convenienceFee = 99;
```

**Rationale**: While extracting these to a shared constant would be ideal for maintainability, the current codebase structure (single HTML file with inline JavaScript) makes local constants the most straightforward approach that maintains consistency with existing patterns.

### 2. renderCart() Function

**Current Signature**: `renderCart()`

**Modifications Required**:

1. **Fee Calculation Section** (lines ~7667-7669):
```javascript
// Current:
const subtotal = this.cart.reduce((sum, item) => sum + (item.price * item.quantity), 0);
const shipping = 50;
const total = subtotal + shipping;

// Updated:
const subtotal = this.cart.reduce((sum, item) => sum + (item.price * item.quantity), 0);
const deliveryFee = 99;
const convenienceFee = 99;
const total = subtotal + deliveryFee + convenienceFee;
```

2. **Display Update** (lines ~7671-7672):
```javascript
// Current:
document.getElementById('cart-subtotal').textContent = `₱${subtotal.toFixed(2)}`;
document.getElementById('cart-total').textContent = `₱${total.toFixed(2)}`;

// Updated: Add delivery fee and convenience fee display elements
// Note: This requires corresponding HTML structure updates
```

**HTML Structure Requirements**: The cart view HTML must include display elements for both fees. Current structure only shows subtotal and total.

### 3. renderCheckoutSummary() Function

**Current Signature**: `renderCheckoutSummary()`

**Modifications Required**:

1. **Fee Calculation Section** (lines ~7685-7687):
```javascript
// Current:
const subtotal = this.cart.reduce((sum, item) => sum + (item.price * item.quantity), 0);
const shipping = 50;
const total = subtotal + shipping;

// Updated:
const subtotal = this.cart.reduce((sum, item) => sum + (item.price * item.quantity), 0);
const deliveryFee = 99;
const convenienceFee = 99;
const total = subtotal + deliveryFee + convenienceFee;
```

2. **Display HTML** (lines ~7700-7708):
```javascript
// Current: Shows only Subtotal, Shipping Fee, and Total

// Updated: Add convenience fee line item between shipping fee and total
<div style="display: flex; justify-content: space-between; margin-bottom: 0.5rem;">
  <span>Convenience Fee:</span>
  <span style="font-weight: 600;">₱${convenienceFee.toFixed(2)}</span>
</div>
```

### 4. placeOrder() Function

**Current Signature**: `async placeOrder(orderData)`

**Modifications Required**:

1. **Fee Calculation Section** (lines ~7719-7721):
```javascript
// Current:
const subtotal = this.cart.reduce((sum, item) => sum + (item.price * item.quantity), 0);
const shippingFee = 50;
const totalAmount = subtotal + shippingFee;

// Updated:
const subtotal = this.cart.reduce((sum, item) => sum + (item.price * item.quantity), 0);
const deliveryFee = 99;
const convenienceFee = 99;
const totalAmount = subtotal + deliveryFee + convenienceFee;
```

2. **Order Object Structure** (lines ~7723-7745):
```javascript
// Current:
const order = {
  // ... other fields
  subtotal: subtotal,
  shipping_fee: shippingFee,
  total_amount: totalAmount,
  // ... other fields
};

// Updated:
const order = {
  // ... other fields
  subtotal: subtotal,
  shipping_fee: deliveryFee,  // Renamed variable but same field
  convenience_fee: convenienceFee,  // NEW FIELD
  total_amount: totalAmount,
  // ... other fields
};
```

3. **Supabase Insert** (lines ~7753-7768):
```javascript
// Current:
const { data: orderData, error: orderError } = await supabaseClient
  .from('orders')
  .insert({
    // ... other fields
    subtotal: order.subtotal,
    shipping_fee: order.shipping_fee,
    total_amount: order.total_amount,
    // ... other fields
  })

// Updated: Add convenience_fee field
const { data: orderData, error: orderError } = await supabaseClient
  .from('orders')
  .insert({
    // ... other fields
    subtotal: order.subtotal,
    shipping_fee: order.shipping_fee,
    convenience_fee: order.convenience_fee,  // NEW FIELD
    total_amount: order.total_amount,
    // ... other fields
  })
```

## Data Models

### Order Object Structure

**Current Structure**:
```javascript
{
  id: string,
  order_number: string,
  user_id: string,
  customer_name: string,
  customer_email: string,
  customer_phone: string,
  shipping_address: string,
  shipping_city: string,
  shipping_postal: string,
  payment_method: string,
  subtotal: number,
  shipping_fee: number,
  total_amount: number,
  status: string,
  status_history: array,
  created_at: string,
  order_items: array,
  items: array
}
```

**Updated Structure** (changes highlighted):
```javascript
{
  id: string,
  order_number: string,
  user_id: string,
  customer_name: string,
  customer_email: string,
  customer_phone: string,
  shipping_address: string,
  shipping_city: string,
  shipping_postal: string,
  payment_method: string,
  subtotal: number,
  shipping_fee: number,           // Value changes from 50 to 99
  convenience_fee: number,         // NEW FIELD - value is 99
  total_amount: number,            // Calculation changes to include both fees
  status: string,
  status_history: array,
  created_at: string,
  order_items: array,
  items: array
}
```

### Database Schema Considerations

**Assumption**: The Supabase `orders` table schema needs to support the new `convenience_fee` field.

**Required Schema Update**:
```sql
ALTER TABLE orders ADD COLUMN convenience_fee DECIMAL(10,2);
```

**Migration Strategy**: 
- For existing orders without `convenience_fee`, the field will be NULL
- This is acceptable as the fee was not charged on those orders
- New orders will always include the `convenience_fee` value

## Error Handling

### Calculation Errors

**Scenario**: Floating-point arithmetic errors in fee calculations

**Mitigation**: Use `.toFixed(2)` consistently for all monetary displays and round to 2 decimal places before storage

**Implementation**:
```javascript
const total = Math.round((subtotal + deliveryFee + convenienceFee) * 100) / 100;
```

### Display Errors

**Scenario**: Missing HTML elements for fee display

**Mitigation**: 
- Verify all required DOM elements exist before rendering
- Provide fallback display if elements are missing
- Log warnings to console for debugging

**Implementation**:
```javascript
const subtotalElement = document.getElementById('cart-subtotal');
if (!subtotalElement) {
  console.warn('Cart subtotal element not found');
  return;
}
```

### Database Errors

**Scenario**: Supabase insert fails due to missing `convenience_fee` column

**Mitigation**:
- Wrap Supabase operations in try-catch blocks (already implemented)
- Provide user-friendly error messages
- Fall back to local storage for demo users

**Current Implementation**: The existing code already handles Supabase errors appropriately and falls back to localStorage for demo users.

## Testing Strategy

### Test Approach

This feature involves straightforward fee calculation and display updates. The changes are deterministic with fixed fee values and simple arithmetic. **Property-based testing is NOT appropriate** for this feature because:

1. **Fixed Configuration Values**: The fees are constants (₱99 each), not variable inputs
2. **Simple Arithmetic**: Total = Subtotal + 99 + 99 (no complex logic)
3. **No Input Variation**: The fee values don't vary with different inputs
4. **UI Display Logic**: Much of the change is HTML rendering, not algorithmic

**Recommended Testing Approach**: Example-based unit tests and manual UI testing

### Unit Tests

**Test Framework**: Jest or similar JavaScript testing framework

**Test Cases**:

1. **Fee Calculation Tests**:
```javascript
describe('Fee Calculations', () => {
  test('calculates total with delivery and convenience fees', () => {
    const subtotal = 100;
    const deliveryFee = 99;
    const convenienceFee = 99;
    const total = subtotal + deliveryFee + convenienceFee;
    expect(total).toBe(298);
  });

  test('handles zero subtotal correctly', () => {
    const subtotal = 0;
    const deliveryFee = 99;
    const convenienceFee = 99;
    const total = subtotal + deliveryFee + convenienceFee;
    expect(total).toBe(198);
  });

  test('handles decimal subtotals correctly', () => {
    const subtotal = 123.45;
    const deliveryFee = 99;
    const convenienceFee = 99;
    const total = subtotal + deliveryFee + convenienceFee;
    expect(total).toBeCloseTo(321.45, 2);
  });
});
```

2. **Order Object Tests**:
```javascript
describe('Order Object Creation', () => {
  test('includes convenience_fee in order object', () => {
    const order = createOrder(mockOrderData);
    expect(order).toHaveProperty('convenience_fee');
    expect(order.convenience_fee).toBe(99);
  });

  test('includes shipping_fee with updated value', () => {
    const order = createOrder(mockOrderData);
    expect(order.shipping_fee).toBe(99);
  });

  test('calculates total_amount correctly', () => {
    const order = createOrder(mockOrderData);
    const expectedTotal = order.subtotal + 99 + 99;
    expect(order.total_amount).toBe(expectedTotal);
  });
});
```

3. **Display Format Tests**:
```javascript
describe('Fee Display Formatting', () => {
  test('formats delivery fee with peso symbol and decimals', () => {
    const formatted = formatCurrency(99);
    expect(formatted).toBe('₱99.00');
  });

  test('formats convenience fee with peso symbol and decimals', () => {
    const formatted = formatCurrency(99);
    expect(formatted).toBe('₱99.00');
  });
});
```

### Integration Tests

**Test Scenarios**:

1. **Cart View Integration**:
   - Add items to cart
   - Verify subtotal calculation
   - Verify delivery fee displays as ₱99.00
   - Verify convenience fee displays as ₱99.00
   - Verify total = subtotal + 198

2. **Checkout View Integration**:
   - Proceed to checkout with items in cart
   - Verify all fees display correctly
   - Verify fee breakdown shows all three components
   - Verify total matches cart total

3. **Order Placement Integration**:
   - Complete checkout process
   - Verify order object contains all fee fields
   - Verify Supabase insert includes convenience_fee
   - Verify stored total_amount is correct

### Manual Testing Checklist

- [ ] Empty cart shows fees correctly (subtotal ₱0, fees ₱198, total ₱198)
- [ ] Cart with single item calculates correctly
- [ ] Cart with multiple items calculates correctly
- [ ] Cart with decimal prices calculates correctly
- [ ] Checkout summary matches cart totals
- [ ] Fee labels are clear and correctly spelled
- [ ] All monetary values show peso symbol (₱)
- [ ] All monetary values show two decimal places
- [ ] Order confirmation shows correct total
- [ ] Order record in database contains all fee fields
- [ ] Mobile view displays fees correctly
- [ ] Tablet view displays fees correctly
- [ ] Desktop view displays fees correctly

### Edge Cases to Test

1. **Very Large Subtotals**: Ensure formatting works with large numbers (e.g., ₱10,000+)
2. **Very Small Subtotals**: Ensure fees are still applied correctly (e.g., ₱1.00 subtotal)
3. **Floating Point Precision**: Test with subtotals like ₱123.456 (should round to ₱123.46)
4. **Empty Cart**: Verify fees are still shown (or handled appropriately)
5. **Demo Users vs Real Users**: Verify both localStorage and Supabase paths work correctly

### Regression Testing

**Areas to Verify**:
- Existing order history displays correctly (old orders without convenience_fee)
- Cart quantity updates still work correctly
- Remove from cart still works correctly
- Checkout form validation still works correctly
- Payment method selection still works correctly
- Order status tracking still works correctly

### Test Data

**Sample Cart for Testing**:
```javascript
const testCart = [
  { id: 1, name: 'Carrots', price: 50, quantity: 2 },  // ₱100
  { id: 2, name: 'Potatoes', price: 45, quantity: 1 }  // ₱45
];
// Expected: Subtotal ₱145, Delivery ₱99, Convenience ₱99, Total ₱343
```

### Performance Testing

**Not Required**: The changes involve simple arithmetic and do not introduce performance concerns. The existing rendering performance is adequate.

### Accessibility Testing

**Considerations**:
- Verify screen readers announce fee amounts correctly
- Ensure fee labels are semantically correct
- Verify keyboard navigation still works in checkout flow

**Note**: Full accessibility validation requires manual testing with assistive technologies.

## Implementation Notes

### Code Consistency

**Variable Naming**:
- Use `deliveryFee` (camelCase) in JavaScript code
- Use `shipping_fee` (snake_case) in database fields (maintains existing convention)
- Use "Delivery Fee" or "Shipping Fee" in user-facing labels (both acceptable)
- Use `convenienceFee` (camelCase) in JavaScript code
- Use `convenience_fee` (snake_case) in database fields
- Use "Convenience Fee" in user-facing labels

### Backward Compatibility

**Existing Orders**: Orders placed before this update will not have a `convenience_fee` field. This is acceptable as:
- The fee was not charged on those orders
- NULL values in the database are appropriate
- Display logic should handle NULL gracefully (show ₱0.00 or omit the line item)

### Future Considerations

**Fee Configuration**: Currently, fees are hardcoded. Future enhancements could include:
- Admin panel to configure fee amounts
- Different fees based on order value or location
- Promotional fee waivers
- Dynamic fee calculation based on external factors

**Recommendation**: For now, maintain hardcoded values for simplicity. If fee changes become frequent, consider extracting to a configuration object or database table.

## Deployment Considerations

### Pre-Deployment Checklist

1. **Database Migration**: Ensure `convenience_fee` column exists in production `orders` table
2. **Backup**: Create database backup before deployment
3. **Testing**: Complete all manual testing in staging environment
4. **Documentation**: Update any user-facing documentation about fees

### Deployment Steps

1. Run database migration to add `convenience_fee` column
2. Deploy updated `maaps-website.html` file
3. Clear browser caches if necessary
4. Monitor first few orders for correct fee application
5. Verify order records in database contain all fee fields

### Rollback Plan

**If Issues Occur**:
1. Revert to previous version of `maaps-website.html`
2. Database rollback not required (new column can remain, will just be NULL)
3. Investigate and fix issues in development environment
4. Re-deploy after fixes are verified

### Monitoring

**Post-Deployment Monitoring**:
- Check first 10-20 orders for correct fee values
- Monitor for any JavaScript errors in browser console
- Verify Supabase insert operations succeed
- Check for customer support inquiries about fees

## Summary

This design provides a straightforward implementation for updating the checkout fee structure. The changes are localized to three functions and follow existing code patterns. The implementation maintains backward compatibility with existing orders while properly applying the new fee structure to all future orders.

**Key Changes**:
- Delivery fee: ₱50 → ₱99
- New convenience fee: ₱99
- Total calculation: Subtotal + Delivery Fee + Convenience Fee
- Order records include both fee values
- UI displays clear fee breakdown

**Testing Focus**: Example-based unit tests for calculations, integration tests for end-to-end flow, and thorough manual testing of UI display and user experience.
