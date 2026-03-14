-- MAAPS Supabase Schema
-- Run this SQL in your Supabase SQL Editor

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- PROFILES TABLE (extends Supabase auth.users)
-- ============================================
CREATE TABLE public.profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  full_name TEXT,
  phone TEXT,
  address TEXT,
  city TEXT,
  postal_code TEXT,
  role TEXT DEFAULT 'user' CHECK (role IN ('user', 'admin')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS on profiles
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Profiles policies
CREATE POLICY "Users can view their own profile" ON public.profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile" ON public.profiles
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Admins can view all profiles" ON public.profiles
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- Function to handle new user signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name)
  VALUES (NEW.id, NEW.email, NEW.raw_user_meta_data->>'full_name');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger for new user signup
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ============================================
-- PRODUCTS TABLE
-- ============================================
CREATE TABLE public.products (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  price DECIMAL(10, 2) NOT NULL,
  unit TEXT DEFAULT 'kg',
  category TEXT,
  image_url TEXT,
  stock_quantity INTEGER DEFAULT 100,
  seller_name TEXT DEFAULT 'MAAPS Farm',
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS on products
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;

-- Products policies (everyone can view active products)
CREATE POLICY "Anyone can view active products" ON public.products
  FOR SELECT USING (is_active = true);

CREATE POLICY "Admins can manage products" ON public.products
  FOR ALL USING (
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- ============================================
-- ORDERS TABLE
-- ============================================
CREATE TABLE public.orders (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  order_number TEXT UNIQUE NOT NULL,
  user_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  customer_name TEXT NOT NULL,
  customer_email TEXT NOT NULL,
  customer_phone TEXT NOT NULL,
  shipping_address TEXT NOT NULL,
  shipping_city TEXT NOT NULL,
  shipping_postal TEXT,
  payment_method TEXT NOT NULL CHECK (payment_method IN ('gcash', 'cash')),
  subtotal DECIMAL(10, 2) NOT NULL,
  shipping_fee DECIMAL(10, 2) DEFAULT 50.00,
  total_amount DECIMAL(10, 2) NOT NULL,
  status TEXT DEFAULT 'pending' CHECK (status IN (
    'pending',
    'confirmed',
    'processing',
    'shipped',
    'out_for_delivery',
    'delivered',
    'cancelled'
  )),
  status_history JSONB DEFAULT '[]'::jsonb,
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS on orders
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;

-- Orders policies
CREATE POLICY "Users can view their own orders" ON public.orders
  FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Users can create orders" ON public.orders
  FOR INSERT WITH CHECK (user_id = auth.uid());

CREATE POLICY "Admins can view all orders" ON public.orders
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
  );

CREATE POLICY "Admins can update orders" ON public.orders
  FOR UPDATE USING (
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- ============================================
-- ORDER ITEMS TABLE
-- ============================================
CREATE TABLE public.order_items (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  order_id UUID REFERENCES public.orders(id) ON DELETE CASCADE NOT NULL,
  product_id UUID REFERENCES public.products(id) ON DELETE SET NULL,
  product_name TEXT NOT NULL,
  product_price DECIMAL(10, 2) NOT NULL,
  quantity INTEGER NOT NULL,
  subtotal DECIMAL(10, 2) NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS on order_items
ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;

-- Order items policies
CREATE POLICY "Users can view their own order items" ON public.order_items
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM public.orders WHERE orders.id = order_items.order_id AND orders.user_id = auth.uid())
  );

CREATE POLICY "Users can create order items" ON public.order_items
  FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM public.orders WHERE orders.id = order_items.order_id AND orders.user_id = auth.uid())
  );

CREATE POLICY "Admins can view all order items" ON public.order_items
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- ============================================
-- INDEXES FOR PERFORMANCE
-- ============================================
CREATE INDEX idx_orders_user_id ON public.orders(user_id);
CREATE INDEX idx_orders_status ON public.orders(status);
CREATE INDEX idx_orders_created_at ON public.orders(created_at DESC);
CREATE INDEX idx_order_items_order_id ON public.order_items(order_id);
CREATE INDEX idx_products_category ON public.products(category);

-- ============================================
-- FUNCTION TO GENERATE ORDER NUMBER
-- ============================================
CREATE OR REPLACE FUNCTION generate_order_number()
RETURNS TEXT AS $$
DECLARE
  new_number TEXT;
BEGIN
  new_number := 'MAAPS-' || TO_CHAR(NOW(), 'YYYYMMDD') || '-' || LPAD(FLOOR(RANDOM() * 10000)::TEXT, 4, '0');
  RETURN new_number;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- FUNCTION TO UPDATE ORDER STATUS WITH HISTORY
-- ============================================
CREATE OR REPLACE FUNCTION update_order_status(
  p_order_id UUID,
  p_new_status TEXT,
  p_notes TEXT DEFAULT NULL
)
RETURNS VOID AS $$
DECLARE
  current_history JSONB;
  new_entry JSONB;
BEGIN
  -- Get current history
  SELECT status_history INTO current_history FROM public.orders WHERE id = p_order_id;
  
  -- Create new history entry
  new_entry := jsonb_build_object(
    'status', p_new_status,
    'timestamp', NOW(),
    'notes', p_notes
  );
  
  -- Update order
  UPDATE public.orders
  SET 
    status = p_new_status,
    status_history = current_history || new_entry,
    updated_at = NOW()
  WHERE id = p_order_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- INSERT DEFAULT PRODUCTS
-- ============================================
INSERT INTO public.products (name, description, price, unit, category, seller_name, image_url) VALUES
  ('Sweet Potato', 'Fresh and organic sweet potatoes from local farms', 45.00, 'kg', 'Root Crops', 'MAAPS Farm', 'List of produce/Sweet Potato.jpg'),
  ('Cassava Root', 'Premium quality cassava root', 35.00, 'kg', 'Root Crops', 'MAAPS Farm', 'List of produce/Cassava Root.jpg'),
  ('Potato', 'Farm-fresh potatoes perfect for any dish', 55.00, 'kg', 'Root Crops', 'MAAPS Farm', 'List of produce/Potato.jpg'),
  ('Carrots', 'Crisp and sweet carrots', 60.00, 'kg', 'Vegetables', 'MAAPS Farm', 'List of produce/Carrots.jpg'),
  ('Squash', 'Locally grown squash', 40.00, 'kg', 'Vegetables', 'MAAPS Farm', 'List of produce/Squash.jpg'),
  ('Ginger', 'Fresh ginger root with strong aroma', 120.00, 'kg', 'Spices', 'MAAPS Farm', 'List of produce/Ginger.jpg'),
  ('Garlic', 'Aromatic garlic bulbs', 150.00, 'kg', 'Spices', 'MAAPS Farm', 'List of produce/Garlic.jpg'),
  ('Red Onion', 'Premium red onions', 80.00, 'kg', 'Vegetables', 'MAAPS Farm', 'List of produce/Red Onion.jpg'),
  ('Green Chili', 'Spicy green chili peppers', 100.00, 'kg', 'Spices', 'MAAPS Farm', 'List of produce/Green Chili.jpg');

-- ============================================
-- CREATE ADMIN USER
-- ============================================
-- STEP 1: First, go to your Supabase Dashboard > Authentication > Users
-- STEP 2: Click "Add User" and create:
--         Email: admin@admin.com
--         Password: password
--         (Check "Auto Confirm User" to skip email verification)
-- 
-- STEP 3: After creating the user, run this SQL to make them admin:
UPDATE public.profiles SET role = 'admin' WHERE email = 'admin@admin.com';

-- ============================================
-- ALTERNATIVE: Create admin via SQL (if you have the user's UUID)
-- ============================================
-- INSERT INTO public.profiles (id, email, full_name, role)
-- VALUES ('your-user-uuid-here', 'admin@admin.com', 'Admin User', 'admin')
-- ON CONFLICT (id) DO UPDATE SET role = 'admin';

