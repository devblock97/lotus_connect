# Lotus Connect - Social Media Post Feature Specification & Integration Guide

**Document Version:** 1.0.0  
**Project:** Lotus Connect  
**Author:** Lotus Connect Engineering  
**Date:** October 2026  
**Status:** Approved & Implemented  

---

## 1. Executive Summary

This document specifies the end-to-end architecture, API contracts, state management, and user interaction flows for the **Social Media Post Feature** in Lotus Connect (`lotus_connect` Flutter client and `lotus_connect_system` Axum/Rust backend services).

The feature provides Facebook and Instagram inspired social experiences:
- **Rich Post Creation**: Text content, custom multi-color gradient cards, multi-image and video picking, feeling/activity status, location tagging, and privacy audience controls (*Public*, *Friends*, *Only me*).
- **In-Place Post Editing**: Live editing of existing posts, pre-filling text and audience, managing current remote attachments, adding new media, and seamless feed updating.
- **Secure Post Deletion**: Author-only deletion enforced by gateway and feed services, protected with a non-destructive native confirmation dialog.
- **Engagement & Interactions**: Double-tap animated heart likes, bookmarking/saving, link copying to clipboard, and report/hide moderation options.

---

## 2. System Architecture

The client follows **Clean Architecture** with **Riverpod** state management, interfacing with the backend gateway and feed microservices.

```
+-----------------------------------------------------------------------------------+
|                           PRESENTATION LAYER (Flutter)                            |
|                                                                                   |
|  HomeScreen   <--->   PostCard          CreatePostBar                             |
|                           |                   |                                   |
|                           v                   v                                   |
|                   PostOptionsSheet ---> CreatePostScreen                          |
|                   (Author / Viewer)     (Create & Edit mode)                      |
|                                         ├── PostPrivacySheet (Audience)           |
|                                         ├── PostFeelingSheet (Emoji & Label)      |
|                                         └── PostLocationSheet (Geo tag)           |
+-----------------------------------------------------------------------------------+
                                         |
                                         v
+-----------------------------------------------------------------------------------+
|                        APPLICATION LAYER (Riverpod State)                         |
|                                                                                   |
|  FeedNotifier (FeedState)             CreatePostNotifier (CreatePostState)        |
|  - addPost(newPost)                   - initializeForEdit(postToEdit)             |
|  - updatePost(updatedPost)            - addMediaPaths(paths)                      |
|  - deletePost(postId)                 - removeExistingMediaAt(index)              |
|  - toggleLike(postId)                 - submitPost()                              |
+-----------------------------------------------------------------------------------+
                                         |
                                         v
+-----------------------------------------------------------------------------------+
|                        DOMAIN LAYER (Clean Architecture)                          |
|                                                                                   |
|  CreatePostUseCase   UpdatePostUseCase   DeletePostUseCase   GetFeedUseCase       |
|            \                 |                  /                  /             |
|             +-----------------+------------------+-----------------+              |
|                                       |                                           |
|                                       v                                           |
|                           FeedRepository (Interface)                              |
+-----------------------------------------------------------------------------------+
                                         |
                                         v
+-----------------------------------------------------------------------------------+
|                            DATA LAYER (Infrastructure)                            |
|                                                                                   |
|  FeedRepositoryImpl  --->  FeedRemoteDataSource  --->  DioClient (JWT Interceptor)|
+-----------------------------------------------------------------------------------+
                                         |
                                  HTTPS REST API
                                         v
+-----------------------------------------------------------------------------------+
|                        BACKEND (lotus_connect_system)                             |
|                                                                                   |
|  API Gateway (Axum / Port 8080)                                                   |
|  ├── POST   /api/v1/posts          -> create_post_handler                         |
|  ├── PUT    /api/v1/posts/:post_id -> update_post_handler                         |
|  ├── DELETE /api/v1/posts/:post_id -> delete_post_handler                         |
|  ├── POST   /api/v1/media/upload   -> media_upload_handler                        |
|  └── GET    /api/v1/feed           -> get_feed_handler                            |
|                                                                                   |
|  Persistence: PostgreSQL & MinIO Object Storage                                   |
+-----------------------------------------------------------------------------------+
```

---

## 3. End-to-End Workflow Diagrams

### 3.1 Post Creation Workflow

```
[User] 
  │ 1. Inputs content / picks media / selects audience
  ▼
[CreatePostScreen]
  │ 2. submitPost()
  ▼
[CreatePostNotifier]
  │ 3. call(CreatePostParams)
  ▼
[CreatePostUseCase]
  │ 4. If filePaths exist: uploadFiles(paths)
  ├───► POST /api/v1/media/upload ───► [API Gateway] ───► [MinIO/Storage]
  │ 5. Returns uploaded media items
  ▼
[CreatePostUseCase]
  │ 6. createPost(content, mediaItems, visibility)
  ├───► POST /api/v1/posts ──────────► [API Gateway] ───► [Feed Service]
  │ 7. Returns new PostItem JSON                             │ (Inserts PostgreSQL)
  ▼                                                          ▼
[CreatePostNotifier]
  │ 8. feedNotifier.addPost(newPost)
  ▼
[FeedNotifier] ───► Prepends post to live feed
  │ 9. UI shows SnackBar "Post shared successfully!" & pops screen
```

### 3.2 Post Edit Workflow

```
[User]
  │ 1. Taps "..." on PostCard
  ▼
[PostOptionsSheet] (Author Mode)
  │ 2. Taps "Edit post"
  ▼
[CreatePostScreen (Edit Mode)]
  │ 3. initializeForEdit(postToEdit)
  │    (pre-fills content, audience, and existing network media items)
  ▼
[User]
  │ 4. Edits text / removes existing media / adds new local files
  │ 5. Taps "Save"
  ▼
[CreatePostNotifier] ───► [UpdatePostUseCase]
  │ 6. If new files: uploadFiles(newPaths)
  │ 7. Merges: existingMediaItems + newlyUploadedMedia
  │ 8. updatePost(postId, content, mergedMedia, visibility)
  ├───► PUT /api/v1/posts/:postId ───► [Feed Service] (Verifies author ownership)
  │ 9. Returns updated PostItem JSON
  ▼
[CreatePostNotifier]
  │ 10. feedNotifier.updatePost(updatedPost)
  ▼
[FeedNotifier] ───► Replaces post in-place in live feed state
  │ 11. UI shows SnackBar "Post updated successfully!" & pops screen
```

### 3.3 Post Deletion Workflow

```
[User]
  │ 1. Taps "..." on PostCard
  ▼
[PostOptionsSheet]
  │ 2. Taps "Delete post" (Destructive red)
  ▼
[Confirmation Dialog]
  │ 3. Prompts: "Are you sure you want to delete this post? This cannot be undone."
  ├─── User taps "Cancel" ───► Closes dialog (No changes made)
  └─── User taps "Delete"
         │
         ▼
[FeedNotifier.deletePost(postId)]
  │ 4. deletePost(postId)
  ▼
[DeletePostUseCase] ───► [FeedRepositoryImpl]
  ├───► DELETE /api/v1/posts/:postId ───► [Feed Service] (Enforces author ownership)
  │ 5. Returns HTTP 200 OK {"success": true}
  ▼
[FeedNotifier]
  │ 6. removePost(postId) (Removes post from state.posts list)
  ▼
[HomeScreen] ───► Feed card removed immediately with "Post deleted successfully." toast
```

---

## 4. Backend API Contract Specification

All endpoints require JWT Bearer Authentication (`Authorization: Bearer <access_token>`).

### 4.1 Create Post
- **Endpoint:** `POST /api/v1/posts`
- **Request Body:**
```json
{
  "content": "Exploring the sunny coast! ☀️",
  "mediaItems": [
    {
      "url": "https://storage.lotusconnect.app/media/p1.jpg",
      "thumbnailUrl": "https://storage.lotusconnect.app/media/p1_thumb.jpg",
      "mimeType": "image/jpeg",
      "fileSize": 204800,
      "width": 1080,
      "height": 1350
    }
  ],
  "visibility": "public"
}
```
- **Response:** `201 Created` returning the created `PostItem`.

### 4.2 Update Post
- **Endpoint:** `PUT /api/v1/posts/:post_id` (also accepts `PATCH`)
- **Request Body:**
```json
{
  "content": "Updated caption text",
  "mediaItems": [
    {
      "url": "https://storage.lotusconnect.app/media/p1.jpg",
      "mimeType": "image/jpeg"
    }
  ],
  "visibility": "friends"
}
```
- **Response:** `200 OK` returning updated `PostItem`.
- **Security:** Returns `403 Forbidden` if `current_user_id != post.author_id`.

### 4.3 Delete Post
- **Endpoint:** `DELETE /api/v1/posts/:post_id`
- **Response:** `200 OK`
```json
{
  "success": true,
  "message": "Post deleted successfully"
}
```
- **Security:** Returns `403 Forbidden` if `current_user_id != post.author_id`.

### 4.4 Media Upload
- **Endpoint:** `POST /api/v1/media/upload`
- **Form Data:** Multi-part file uploads (`files[]`).
- **Response:** `200 OK` returning array of uploaded `PostMediaItem` objects.

---

## 5. Security & Ownership Matrix

| User Role | Available Post Actions | Backend Enforcement |
|-----------|------------------------|---------------------|
| **Author** | • Edit Post (`CreatePostScreen` in Edit mode)<br>• Edit Audience (`PostPrivacySheet`)<br>• Delete Post (with confirmation dialog)<br>• Copy Link | JWT Claim `sub == author_id`<br>Returns 403 Forbidden on mismatch |
| **Viewer** | • Save Post (Bookmarks)<br>• Hide Post (Local feed exclusion)<br>• Report Post (Moderation queue)<br>• Copy Link | Read-only operations;<br>Cannot mutate post content or visibility |

---

## 6. Verification and Test Suite

The feature is protected by comprehensive unit and widget test suites:
- **`UpdatePostUseCaseTest`**: Verifies validation rules, local file uploading, media merging, and error propagation.
- **`DeletePostUseCaseTest`**: Verifies validation and API deletion delegation.
- **`CreatePostNotifierTest`**: Validates edit initialization, media removals, and live feed updates.
- **`FeedNotifierTest`**: Verifies `updatePost` and `deletePost` state modifications.
- **`PostOptionsSheetTest`**: Tests author vs viewer action branches and deletion confirmation dialog.
- **`CreatePostScreenTest`**: Tests form rendering, button toggles, and edit mode submission.

**Test Results:**  
- Total Tests: **56 / 56 Passing** (100% success rate)  
- Static Analysis: **0 Warnings / 0 Errors** (`flutter analyze` clean)
