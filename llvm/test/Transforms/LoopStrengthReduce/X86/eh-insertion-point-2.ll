; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -S -loop-reduce < %s | FileCheck %s

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

declare void @maybe_throws()
declare void @use1(i1)

define void @is_not_42(i8* %baseptr, i8* %finalptr) local_unnamed_addr align 2 personality i8* undef {
; CHECK-LABEL: @is_not_42(
; CHECK-NEXT:  preheader:
; CHECK-NEXT:    br label [[HEADER:%.*]]
; CHECK:       header:
; CHECK-NEXT:    [[PTR:%.*]] = phi i8* [ [[INCPTR:%.*]], [[LATCH:%.*]] ], [ [[BASEPTR:%.*]], [[PREHEADER:%.*]] ]
; CHECK-NEXT:    invoke void @maybe_throws()
; CHECK-NEXT:    to label [[LATCH]] unwind label [[LPAD:%.*]]
; CHECK:       lpad:
; CHECK-NEXT:    [[TMP0:%.*]] = landingpad { i8*, i32 }
; CHECK-NEXT:    catch i8* inttoptr (i64 42 to i8*)
; CHECK-NEXT:    [[PTR_IS_NOT_42:%.*]] = icmp ne i8* [[PTR]], inttoptr (i64 42 to i8*)
; CHECK-NEXT:    call void @use1(i1 [[PTR_IS_NOT_42]])
; CHECK-NEXT:    ret void
; CHECK:       latch:
; CHECK-NEXT:    [[INCPTR]] = getelementptr inbounds i8, i8* [[PTR]], i64 1
; CHECK-NEXT:    br label [[HEADER]]
;
preheader:
  br label %header

header:
  %ptr = phi i8* [ %incptr, %latch ], [ %baseptr, %preheader ]
  invoke void @maybe_throws() to label %latch unwind label %lpad

lpad:
  landingpad { i8*, i32 } catch i8* inttoptr (i64 42 to i8*)
  %ptr_is_not_42 = icmp ne i8* %ptr, inttoptr (i64 42 to i8*)
  call void @use1(i1 %ptr_is_not_42)
  ret void

latch:
  %incptr = getelementptr inbounds i8, i8* %ptr, i64 1
  br label %header
}
