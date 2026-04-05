# Chat & Profile Features - Implementation Guide

## Overview
This document describes the new features added to the MAAPS platform:
1. **Image Attachments in Chat** - Users and admins can send images (max 3MB)
2. **Profile Picture Upload** - Users can upload and display profile pictures
3. **Profile Pictures in Chat** - Profile pictures are displayed in chat messages

---

## 🗄️ Database Setup

### Step 1: Run the SQL Schema
You need to run **TWO** SQL files in your Supabase SQL Editor:

1. **First time setup**: Run `chat-system-schema.sql` (if not already done)
2. **New features**: Run `chat-profile-updates.sql`

#### What the schema adds:
- **Messages table updates**: Adds `image_url`, `image_name`, `image_size` columns
- **Profiles table updates**: Adds `profile_picture_url`, `bio`, `updated_at` columns
- **Storage buckets**: Creates `chat-images` and `profile-pictures` buckets
- **Storage policies**: Sets up RLS policies for secure image uploads
- **Triggers**: Auto-updates `updated_at` timestamp on profile changes

### Step 2: Verify Setup
After running the SQL, verify in Supabase:
- Go to **Storage** → Check for `chat-images` and `profile-pictures` buckets
- Go to **Database** → **Tables** → `messages` → Check for new image columns
- Go to **Database** → **Tables** → `profiles` → Check for `profile_picture_url` column

---

## 📸 Feature 1: Image Attachments in Chat

### User Experience
1. **Attach Image**: Click the paperclip icon next to the message input
2. **Select Image**: Choose an image file (max 3MB)
3. **Preview**: Image preview appears below the input with file size
4. **Send**: Click send button to upload and send the image
5. **View**: Images appear in chat messages, click to open full size

### Technical Details
- **File size limit**: 3MB (enforced client-side and can be enforced server-side)
- **Supported formats**: All image formats (jpg, png, gif, webp, etc.)
- **Storage**: Images stored in Supabase Storage bucket `chat-images`
- **Organization**: Files stored in folders by user ID: `{user_id}/{timestamp}_{filename}`
- **Security**: RLS policies ensure users can only upload to their own folder

### Code Components
- **UI**: Image attachment button, file input, preview area
- **Upload**: `ChatSystem.sendMessage()` handles image upload to Supabase Storage
- **Display**: `ChatSystem.renderMessages()` displays images in chat bubbles
- **Styling**: CSS classes for image preview and message images

---

## 👤 Feature 2: Profile Picture Upload

### User Experience
1. **Go to Profile**: Click "Profile" in navigation
2. **Upload Picture**: Click camera icon on profile picture circle
3. **Select Image**: Choose an image (max 3MB)
4. **Preview**: Image appears immediately in the circle
5. **Save**: Click "Save Changes" to upload and save

### Technical Details
- **File size limit**: 3MB
- **Supported formats**: All image formats
- **Storage**: Images stored in `profile-pictures` bucket
- **Organization**: Files stored as `{user_id}/profile_{timestamp}.jpg`
- **Fallback**: If no picture, shows colored circle with user's initial

### Profile Fields
Users can edit:
- Full Name
- Phone
- Location
- Bio
- Profile Picture

**Note**: Email and account name are read-only (displayed but not editable)

---

## 💬 Feature 3: Profile Pictures in Chat

### User Experience
- Profile pictures automatically appear in chat message avatars
- If user has no profile picture, shows colored circle with initial
- Works for both user and admin messages
- Updates in real-time when profile picture is changed

### Technical Details
- **Caching**: Profile data cached in `ChatSystem.userProfiles` object
- **Fetching**: `ChatSystem.getUserProfile()` fetches profiles as needed
- **Display**: Avatar HTML dynamically generated based on profile data
- **Performance**: Batch fetches all unique sender profiles when loading messages

---

## 🔧 Testing Guide

### Test Image Attachments
1. Log in as a user
2. Open chat (green floating button)
3. Click paperclip icon
4. Select an image under 3MB
5. Verify preview appears
6. Send message
7. Verify image appears in chat
8. Click image to open in new tab
9. Log in as admin in another browser
10. Verify admin can see the image

### Test Profile Picture
1. Log in as a user
2. Go to Profile page
3. Click camera icon on profile circle
4. Select an image under 3MB
5. Verify preview appears in circle
6. Fill in other profile fields
7. Click "Save Changes"
8. Verify success message
9. Refresh page and go back to Profile
10. Verify picture is still there

### Test Profile Pictures in Chat
1. Upload a profile picture (see above)
2. Open chat and send a message
3. Verify your profile picture appears in the message avatar
4. Log in as another user/admin
5. Send messages back and forth
6. Verify both profile pictures appear correctly
7. Change your profile picture
8. Send another message
9. Verify new picture appears

---

## 🐛 Troubleshooting

### Images not uploading
- **Check file size**: Must be under 3MB
- **Check Supabase Storage**: Verify buckets exist
- **Check RLS policies**: Verify storage policies are set up
- **Check browser console**: Look for error messages

### Profile picture not saving
- **Check Supabase connection**: Verify `supabaseClient` is initialized
- **Check profiles table**: Verify `profile_picture_url` column exists
- **Check storage bucket**: Verify `profile-pictures` bucket exists
- **Check user permissions**: Verify user is logged in

### Profile pictures not showing in chat
- **Check profiles table**: Verify `profile_picture_url` has data
- **Check image URL**: Open URL directly in browser to verify it works
- **Check browser console**: Look for CORS or loading errors
- **Hard refresh**: Press Ctrl+Shift+R to clear cache

---

## 📝 Important Notes

### Security
- All uploads go through Supabase RLS policies
- Users can only upload to their own folders
- Images are publicly readable (needed for chat display)
- File size limits prevent abuse

### Performance
- Profile pictures are cached to minimize database queries
- Images are lazy-loaded in chat
- Storage uses CDN for fast delivery

### Limitations
- Max file size: 3MB per image
- Supported formats: All image formats
- Storage quota: Depends on your Supabase plan

---

## 🚀 Deployment Checklist

Before pushing to production:
- [ ] Run `chat-profile-updates.sql` in Supabase
- [ ] Verify storage buckets are created
- [ ] Test image upload as user
- [ ] Test image upload as admin
- [ ] Test profile picture upload
- [ ] Test profile pictures display in chat
- [ ] Test on mobile devices
- [ ] Check file size limits work
- [ ] Verify error messages display correctly
- [ ] Test with different image formats

---

## 📞 Support

If you encounter issues:
1. Check browser console for errors
2. Check Supabase logs in dashboard
3. Verify all SQL scripts ran successfully
4. Check storage bucket permissions
5. Verify RLS policies are active

---

## 🎉 Features Summary

✅ **Image Attachments**: Send images in chat (max 3MB)  
✅ **Profile Pictures**: Upload and display profile pictures  
✅ **Chat Avatars**: Profile pictures shown in chat messages  
✅ **Real-time Updates**: Changes reflect immediately  
✅ **Secure Storage**: RLS policies protect user data  
✅ **Mobile Friendly**: Works on all devices  

---

*Last Updated: April 5, 2026*
