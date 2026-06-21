# Supabase Setup Guide for Attendance QR App

## Overview
This app saves student attendance into Supabase and shows a top-right connection status indicator for both teacher and student dashboards.

The student attendance flow is:
1. Student submits attendance in `lib/screens/submission_screen.dart`
2. `StudentService.addAttendance()` writes locally and sends the same record to `attendance_records`
3. Any Supabase insert error is now thrown back to the form layer
4. The student sees a red snackbar if the submission fails

## Required Supabase Tables

### Sessions Table
```sql
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  qr_code TEXT,
  timestamp TEXT,
  is_active BOOLEAN DEFAULT true,
  module TEXT,
  number_of_students INTEGER,
  date TEXT,
  level TEXT,
  timer_minutes INTEGER,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_sessions_created_at ON sessions(created_at);
CREATE INDEX IF NOT EXISTS idx_sessions_is_active ON sessions(is_active);
```

### Attendance Records Table
```sql
CREATE TABLE attendance_records (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id UUID NOT NULL REFERENCES sessions(id) ON DELETE CASCADE,
  student_name TEXT NOT NULL,
  admission_number TEXT NOT NULL,
  module_name TEXT,
  timestamp TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_attendance_session_id ON attendance_records(session_id);
CREATE INDEX IF NOT EXISTS idx_attendance_admission_number ON attendance_records(admission_number);
CREATE INDEX IF NOT EXISTS idx_attendance_timestamp ON attendance_records(timestamp);
```

## Recommended Row-Level Security Policies

Enable RLS and allow authenticated users to insert and select from both tables.

```sql
ALTER TABLE sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE attendance_records ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow authenticated select sessions" ON sessions
FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Allow authenticated insert sessions" ON sessions
FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Allow authenticated update sessions" ON sessions
FOR UPDATE USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Allow authenticated select attendance_records" ON attendance_records
FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Allow authenticated insert attendance_records" ON attendance_records
FOR INSERT WITH CHECK (auth.role() = 'authenticated');
```

If you want to restrict attendance writes to only users who belong to a teacher or student role stored in `auth.users.user_metadata`, you can use:

```sql
CREATE POLICY "Allow authenticated attendance insert by student or teacher" ON attendance_records
FOR INSERT WITH CHECK (
  auth.role() = 'authenticated' AND (
    auth.jwt() ->> 'role' = 'student' OR auth.jwt() ->> 'role' = 'teacher'
  )
);
```

## How the App Submits Attendance

The student submission path is:
- `lib/screens/submission_screen.dart` validates the form
- `lib/services/student_service.dart` creates a `StudentAttendance` entry
- `StudentService.addAttendance()` saves locally and attempts to insert into `attendance_records`
- If Supabase returns an error, the exception bubbles to the screen
- The screen shows a red `SnackBar` with failure details

## Error Notification Behavior

If any error occurs while saving attendance to Supabase, the app now shows a bottom snackbar with:
- red background
- error icon
- message like `Failed to capture attendance: ...`

This ensures the student sees immediate failure feedback instead of silently ignoring the Supabase error.

## Validation Checklist

- Ensure `lib/config/supabase_config.dart` contains the correct project URL and anon key.
- Ensure the student is authenticated before submitting attendance.
- Ensure the `attendance_records` table has `session_id` referencing `sessions(id)`.
- Ensure RLS is enabled and policies allow authenticated inserts and selects.

## Notes

- The app also reads attendance records from `attendance_records` for teacher refresh screens.
- If you receive RLS errors while inserting records, confirm the policy on `attendance_records` allows authenticated users to insert.
- If the student submission still fails with `new row violates row-level security policy`, the fix is in Supabase: update the `attendance_records` policy as shown above.
