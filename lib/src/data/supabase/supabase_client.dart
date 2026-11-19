import "package:riverpod_annotation/riverpod_annotation.dart";
import "package:supabase_flutter/supabase_flutter.dart";

part "supabase_client.g.dart";

/// bootstrap()에서 초기화한 Supabase 클라이언트.
@Riverpod(keepAlive: true)
SupabaseClient supabase(Ref ref) => Supabase.instance.client;
