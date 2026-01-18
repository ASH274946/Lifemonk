# Upload Scripts for Firebase Storage

This folder contains helper scripts to upload content to Firebase Storage.

## Prerequisites

1. **Python 3.7+** installed on your system
2. **Firebase Admin SDK** Python package:
   ```bash
   pip install firebase-admin
   ```
3. **Service Account Key** from Firebase Console

## Getting Service Account Key

1. Go to [Firebase Console](https://console.firebase.google.com/project/lifemonk-68437/settings/serviceaccounts/adminsdk)
2. Click "Generate new private key"
3. Save the JSON file as `serviceAccountKey.json` in this `scripts/` folder
4. **Important**: Do NOT commit this file to version control (already in .gitignore)

## Upload Bytes to Firebase Storage

### Script: `upload_bytes_to_firebase.py`

This script uploads educational content (videos/images) to the `bytes/` folder in Firebase Storage.

#### Usage

**Upload a single file:**
```bash
python upload_bytes_to_firebase.py path/to/video.mp4
```

**Upload all files from a directory:**
```bash
python upload_bytes_to_firebase.py path/to/content/folder/
```

**Upload recursively (including subfolders):**
```bash
python upload_bytes_to_firebase.py path/to/content/folder/ --recursive
```

#### Supported File Types

**Videos:**
- .mp4
- .mov
- .avi
- .mkv
- .webm

**Images:**
- .jpg, .jpeg
- .png
- .gif
- .webp

#### Example

```bash
# Upload all MP4 files from a folder
python upload_bytes_to_firebase.py ./my-educational-videos/

# Output:
# ✅ Initialized Firebase with service account key
# 📂 Found 5 supported files
# 🎯 Target: lifemonk-68437.firebasestorage.app/bytes/
#
# 📤 Uploading vedic_math_trick.mp4... ✅ Uploaded to bytes/vedic_math_trick.mp4
# 📤 Uploading fun_science_fact.mp4... ✅ Uploaded to bytes/fun_science_fact.mp4
# ...
# ✅ Successfully uploaded 5/5 files
```

## File Naming Best Practices

Use descriptive filenames with underscores or hyphens:
- ✅ Good: `vedic_math_multiplication.mp4`, `quick-science-fact.jpg`
- ❌ Avoid: `video1.mp4`, `IMG_1234.jpg`, `Untitled.mov`

The script automatically:
- Converts filenames to readable titles (underscores → spaces)
- Adds metadata (description) based on filename
- Makes files publicly readable

## Verifying Upload

After uploading, verify in:
1. **Firebase Console**: https://console.firebase.google.com/project/lifemonk-68437/storage
2. **Lifemonk App**: Open the Byte section to see your content

## Troubleshooting

### Error: Firebase not initialized
- Make sure `serviceAccountKey.json` exists in the scripts/ folder
- Or set `GOOGLE_APPLICATION_CREDENTIALS` environment variable

### Error: Permission denied
- Check Firebase Storage security rules
- Ensure service account has Storage Admin role

### Files not showing in app
- Wait a few seconds for Firebase to propagate changes
- Pull to refresh in the Byte section
- Check app logs for any errors

## Security Notes

⚠️ **Never commit `serviceAccountKey.json` to version control!**

The service account key provides admin access to your Firebase project. Keep it secure:
- Store it locally only
- Add to .gitignore (already configured)
- Rotate keys periodically
- Use different keys for different environments

## Alternative Upload Methods

### Via Firebase Console (Web)
1. Go to Firebase Console > Storage
2. Navigate to `bytes/` folder
3. Click "Upload file"
4. Select your files

### Via Firebase CLI
```bash
firebase storage:upload local-file.mp4 bytes/remote-name.mp4 --project lifemonk-68437
```

### Via Google Cloud Storage Console
1. Go to https://console.cloud.google.com/storage
2. Select bucket `lifemonk-68437.firebasestorage.app`
3. Navigate to `bytes/` folder
4. Upload files

## Additional Resources

- [Firebase Storage Documentation](https://firebase.google.com/docs/storage)
- [Firebase Admin SDK Python](https://firebase.google.com/docs/admin/setup)
- [Project Firebase Storage Guide](../docs/FIREBASE_STORAGE.md)
