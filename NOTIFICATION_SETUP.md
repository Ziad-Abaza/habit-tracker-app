# Notification Setup Instructions

## If notifications are not working, follow these steps:

### Step 1: Enable Notification Permission
1. Go to your phone's **Settings**
2. Navigate to **Apps** → **Habit**
3. Tap on **Permissions** or **App permissions**
4. Enable **Notifications**

### Step 2: Enable Exact Alarm Permission (Android 12+)
1. Go to your phone's **Settings**
2. Navigate to **Apps** → **Habit**
3. Tap on **Permissions** or **Special app access**
4. Find and tap **Alarms & reminders** or **Schedule exact alarms**
5. **Enable** this permission

### Step 3: Disable Battery Optimization (Optional but Recommended)
1. Go to your phone's **Settings**
2. Navigate to **Apps** → **Habit**
3. Tap on **Battery** or **Battery usage**
4. Select **Unrestricted** or disable battery optimization

### Step 4: Test Notifications
1. Open the Habit app
2. Create a new habit or activity
3. Set the time to **2-3 minutes from now**
4. Save it
5. Wait for the notification to appear

## Troubleshooting

### Check Console Logs
Look for these messages when the app starts:
```
Device timezone: [Your timezone]
Using timezone: [Timezone name]
Notification permission granted: true
Exact alarm permission granted: true
Can schedule exact alarms: true
```

If any show `false`, you need to enable that permission manually.

### Common Issues

**Issue**: "Can schedule exact alarms: false"
**Solution**: Enable "Alarms & reminders" permission in app settings

**Issue**: Notifications appear but at wrong time
**Solution**: Check that the timezone is correct in the logs

**Issue**: No notifications at all
**Solution**: 
1. Check all permissions are granted
2. Disable battery optimization
3. Restart the app
4. Try creating a test notification

## Manual Permission Grant (If automatic request doesn't work)

Since Android 12+, exact alarm permissions cannot be requested automatically in some cases. You must:

1. Open **Settings** on your phone
2. Search for "Alarms & reminders" or "Special app access"
3. Find **Habit** app in the list
4. Enable the permission

This is a system requirement and cannot be bypassed.
