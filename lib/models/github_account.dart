import 'package:hive/hive.dart';

part 'github_account.g.dart';

@HiveType(typeId: 6)
class GithubAccount extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String token;

  GithubAccount({required this.id, required this.name, required this.token});

  String get maskedToken {
    if (token.length <= 8) return '***';
    return '${token.substring(0, 4)}...${token.substring(token.length - 4)}';
  }

  GithubAccount copyWith({String? name, String? token}) {
    return GithubAccount(
      id: id,
      name: name ?? this.name,
      token: token ?? this.token,
    );
  }
}
