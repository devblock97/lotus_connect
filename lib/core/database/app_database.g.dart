// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ConversationTableTable extends ConversationTable
    with TableInfo<$ConversationTableTable, ConversationTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConversationTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 200),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _isPinnedMeta =
      const VerificationMeta('isPinned');
  @override
  late final GeneratedColumn<bool> isPinned = GeneratedColumn<bool>(
      'is_pinned', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_pinned" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isFavouriteMeta =
      const VerificationMeta('isFavourite');
  @override
  late final GeneratedColumn<bool> isFavourite = GeneratedColumn<bool>(
      'is_favourite', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_favourite" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _modelNameMeta =
      const VerificationMeta('modelName');
  @override
  late final GeneratedColumn<String> modelName = GeneratedColumn<String>(
      'model_name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('gemini-1.5-pro'));
  static const VerificationMeta _draftMessageMeta =
      const VerificationMeta('draftMessage');
  @override
  late final GeneratedColumn<String> draftMessage = GeneratedColumn<String>(
      'draft_message', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _systemPromptMeta =
      const VerificationMeta('systemPrompt');
  @override
  late final GeneratedColumn<String> systemPrompt = GeneratedColumn<String>(
      'system_prompt', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isUserToUserMeta =
      const VerificationMeta('isUserToUser');
  @override
  late final GeneratedColumn<bool> isUserToUser = GeneratedColumn<bool>(
      'is_user_to_user', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_user_to_user" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _peerIdMeta = const VerificationMeta('peerId');
  @override
  late final GeneratedColumn<String> peerId = GeneratedColumn<String>(
      'peer_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        title,
        createdAt,
        updatedAt,
        isPinned,
        isFavourite,
        modelName,
        draftMessage,
        systemPrompt,
        isUserToUser,
        peerId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'conversation_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<ConversationTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_pinned')) {
      context.handle(_isPinnedMeta,
          isPinned.isAcceptableOrUnknown(data['is_pinned']!, _isPinnedMeta));
    }
    if (data.containsKey('is_favourite')) {
      context.handle(
          _isFavouriteMeta,
          isFavourite.isAcceptableOrUnknown(
              data['is_favourite']!, _isFavouriteMeta));
    }
    if (data.containsKey('model_name')) {
      context.handle(_modelNameMeta,
          modelName.isAcceptableOrUnknown(data['model_name']!, _modelNameMeta));
    }
    if (data.containsKey('draft_message')) {
      context.handle(
          _draftMessageMeta,
          draftMessage.isAcceptableOrUnknown(
              data['draft_message']!, _draftMessageMeta));
    }
    if (data.containsKey('system_prompt')) {
      context.handle(
          _systemPromptMeta,
          systemPrompt.isAcceptableOrUnknown(
              data['system_prompt']!, _systemPromptMeta));
    }
    if (data.containsKey('is_user_to_user')) {
      context.handle(
          _isUserToUserMeta,
          isUserToUser.isAcceptableOrUnknown(
              data['is_user_to_user']!, _isUserToUserMeta));
    }
    if (data.containsKey('peer_id')) {
      context.handle(_peerIdMeta,
          peerId.isAcceptableOrUnknown(data['peer_id']!, _peerIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ConversationTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ConversationTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      isPinned: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_pinned'])!,
      isFavourite: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_favourite'])!,
      modelName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}model_name'])!,
      draftMessage: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}draft_message']),
      systemPrompt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}system_prompt']),
      isUserToUser: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_user_to_user'])!,
      peerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}peer_id'])!,
    );
  }

  @override
  $ConversationTableTable createAlias(String alias) {
    return $ConversationTableTable(attachedDatabase, alias);
  }
}

class ConversationTableData extends DataClass
    implements Insertable<ConversationTableData> {
  /// Unique identifier for the conversation.
  final String id;

  /// Title of the conversation.
  final String title;

  /// Timestamp when created.
  final DateTime createdAt;

  /// Timestamp when last updated.
  final DateTime updatedAt;

  /// Whether the conversation is pinned.
  final bool isPinned;

  /// Whether the conversation is marked as favourite.
  final bool isFavourite;

  /// Selected AI model for this conversation.
  final String modelName;

  /// Unsaved draft message input text.
  final String? draftMessage;

  /// Optional custom system prompt for this conversation.
  final String? systemPrompt;

  /// Whether the conversation is a user-to-user private chat.
  final bool isUserToUser;

  /// Target peer user ID (UUID) if user-to-user.
  final String peerId;
  const ConversationTableData(
      {required this.id,
      required this.title,
      required this.createdAt,
      required this.updatedAt,
      required this.isPinned,
      required this.isFavourite,
      required this.modelName,
      this.draftMessage,
      this.systemPrompt,
      required this.isUserToUser,
      required this.peerId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_pinned'] = Variable<bool>(isPinned);
    map['is_favourite'] = Variable<bool>(isFavourite);
    map['model_name'] = Variable<String>(modelName);
    if (!nullToAbsent || draftMessage != null) {
      map['draft_message'] = Variable<String>(draftMessage);
    }
    if (!nullToAbsent || systemPrompt != null) {
      map['system_prompt'] = Variable<String>(systemPrompt);
    }
    map['is_user_to_user'] = Variable<bool>(isUserToUser);
    map['peer_id'] = Variable<String>(peerId);
    return map;
  }

  ConversationTableCompanion toCompanion(bool nullToAbsent) {
    return ConversationTableCompanion(
      id: Value(id),
      title: Value(title),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isPinned: Value(isPinned),
      isFavourite: Value(isFavourite),
      modelName: Value(modelName),
      draftMessage: draftMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(draftMessage),
      systemPrompt: systemPrompt == null && nullToAbsent
          ? const Value.absent()
          : Value(systemPrompt),
      isUserToUser: Value(isUserToUser),
      peerId: Value(peerId),
    );
  }

  factory ConversationTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ConversationTableData(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isPinned: serializer.fromJson<bool>(json['isPinned']),
      isFavourite: serializer.fromJson<bool>(json['isFavourite']),
      modelName: serializer.fromJson<String>(json['modelName']),
      draftMessage: serializer.fromJson<String?>(json['draftMessage']),
      systemPrompt: serializer.fromJson<String?>(json['systemPrompt']),
      isUserToUser: serializer.fromJson<bool>(json['isUserToUser']),
      peerId: serializer.fromJson<String>(json['peerId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isPinned': serializer.toJson<bool>(isPinned),
      'isFavourite': serializer.toJson<bool>(isFavourite),
      'modelName': serializer.toJson<String>(modelName),
      'draftMessage': serializer.toJson<String?>(draftMessage),
      'systemPrompt': serializer.toJson<String?>(systemPrompt),
      'isUserToUser': serializer.toJson<bool>(isUserToUser),
      'peerId': serializer.toJson<String>(peerId),
    };
  }

  ConversationTableData copyWith(
          {String? id,
          String? title,
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? isPinned,
          bool? isFavourite,
          String? modelName,
          Value<String?> draftMessage = const Value.absent(),
          Value<String?> systemPrompt = const Value.absent(),
          bool? isUserToUser,
          String? peerId}) =>
      ConversationTableData(
        id: id ?? this.id,
        title: title ?? this.title,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isPinned: isPinned ?? this.isPinned,
        isFavourite: isFavourite ?? this.isFavourite,
        modelName: modelName ?? this.modelName,
        draftMessage:
            draftMessage.present ? draftMessage.value : this.draftMessage,
        systemPrompt:
            systemPrompt.present ? systemPrompt.value : this.systemPrompt,
        isUserToUser: isUserToUser ?? this.isUserToUser,
        peerId: peerId ?? this.peerId,
      );
  ConversationTableData copyWithCompanion(ConversationTableCompanion data) {
    return ConversationTableData(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isPinned: data.isPinned.present ? data.isPinned.value : this.isPinned,
      isFavourite:
          data.isFavourite.present ? data.isFavourite.value : this.isFavourite,
      modelName: data.modelName.present ? data.modelName.value : this.modelName,
      draftMessage: data.draftMessage.present
          ? data.draftMessage.value
          : this.draftMessage,
      systemPrompt: data.systemPrompt.present
          ? data.systemPrompt.value
          : this.systemPrompt,
      isUserToUser: data.isUserToUser.present
          ? data.isUserToUser.value
          : this.isUserToUser,
      peerId: data.peerId.present ? data.peerId.value : this.peerId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ConversationTableData(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isPinned: $isPinned, ')
          ..write('isFavourite: $isFavourite, ')
          ..write('modelName: $modelName, ')
          ..write('draftMessage: $draftMessage, ')
          ..write('systemPrompt: $systemPrompt, ')
          ..write('isUserToUser: $isUserToUser, ')
          ..write('peerId: $peerId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, createdAt, updatedAt, isPinned,
      isFavourite, modelName, draftMessage, systemPrompt, isUserToUser, peerId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConversationTableData &&
          other.id == this.id &&
          other.title == this.title &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isPinned == this.isPinned &&
          other.isFavourite == this.isFavourite &&
          other.modelName == this.modelName &&
          other.draftMessage == this.draftMessage &&
          other.systemPrompt == this.systemPrompt &&
          other.isUserToUser == this.isUserToUser &&
          other.peerId == this.peerId);
}

class ConversationTableCompanion
    extends UpdateCompanion<ConversationTableData> {
  final Value<String> id;
  final Value<String> title;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isPinned;
  final Value<bool> isFavourite;
  final Value<String> modelName;
  final Value<String?> draftMessage;
  final Value<String?> systemPrompt;
  final Value<bool> isUserToUser;
  final Value<String> peerId;
  final Value<int> rowid;
  const ConversationTableCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isPinned = const Value.absent(),
    this.isFavourite = const Value.absent(),
    this.modelName = const Value.absent(),
    this.draftMessage = const Value.absent(),
    this.systemPrompt = const Value.absent(),
    this.isUserToUser = const Value.absent(),
    this.peerId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ConversationTableCompanion.insert({
    required String id,
    required String title,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.isPinned = const Value.absent(),
    this.isFavourite = const Value.absent(),
    this.modelName = const Value.absent(),
    this.draftMessage = const Value.absent(),
    this.systemPrompt = const Value.absent(),
    this.isUserToUser = const Value.absent(),
    this.peerId = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<ConversationTableData> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isPinned,
    Expression<bool>? isFavourite,
    Expression<String>? modelName,
    Expression<String>? draftMessage,
    Expression<String>? systemPrompt,
    Expression<bool>? isUserToUser,
    Expression<String>? peerId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isPinned != null) 'is_pinned': isPinned,
      if (isFavourite != null) 'is_favourite': isFavourite,
      if (modelName != null) 'model_name': modelName,
      if (draftMessage != null) 'draft_message': draftMessage,
      if (systemPrompt != null) 'system_prompt': systemPrompt,
      if (isUserToUser != null) 'is_user_to_user': isUserToUser,
      if (peerId != null) 'peer_id': peerId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ConversationTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? title,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? isPinned,
      Value<bool>? isFavourite,
      Value<String>? modelName,
      Value<String?>? draftMessage,
      Value<String?>? systemPrompt,
      Value<bool>? isUserToUser,
      Value<String>? peerId,
      Value<int>? rowid}) {
    return ConversationTableCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPinned: isPinned ?? this.isPinned,
      isFavourite: isFavourite ?? this.isFavourite,
      modelName: modelName ?? this.modelName,
      draftMessage: draftMessage ?? this.draftMessage,
      systemPrompt: systemPrompt ?? this.systemPrompt,
      isUserToUser: isUserToUser ?? this.isUserToUser,
      peerId: peerId ?? this.peerId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isPinned.present) {
      map['is_pinned'] = Variable<bool>(isPinned.value);
    }
    if (isFavourite.present) {
      map['is_favourite'] = Variable<bool>(isFavourite.value);
    }
    if (modelName.present) {
      map['model_name'] = Variable<String>(modelName.value);
    }
    if (draftMessage.present) {
      map['draft_message'] = Variable<String>(draftMessage.value);
    }
    if (systemPrompt.present) {
      map['system_prompt'] = Variable<String>(systemPrompt.value);
    }
    if (isUserToUser.present) {
      map['is_user_to_user'] = Variable<bool>(isUserToUser.value);
    }
    if (peerId.present) {
      map['peer_id'] = Variable<String>(peerId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConversationTableCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isPinned: $isPinned, ')
          ..write('isFavourite: $isFavourite, ')
          ..write('modelName: $modelName, ')
          ..write('draftMessage: $draftMessage, ')
          ..write('systemPrompt: $systemPrompt, ')
          ..write('isUserToUser: $isUserToUser, ')
          ..write('peerId: $peerId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MessageTableTable extends MessageTable
    with TableInfo<$MessageTableTable, MessageTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessageTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _conversationIdMeta =
      const VerificationMeta('conversationId');
  @override
  late final GeneratedColumn<String> conversationId = GeneratedColumn<String>(
      'conversation_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES conversation_table (id) ON DELETE CASCADE'));
  static const VerificationMeta _senderRoleMeta =
      const VerificationMeta('senderRole');
  @override
  late final GeneratedColumn<String> senderRole = GeneratedColumn<String>(
      'sender_role', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _isErrorMeta =
      const VerificationMeta('isError');
  @override
  late final GeneratedColumn<bool> isError = GeneratedColumn<bool>(
      'is_error', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_error" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('sent'));
  static const VerificationMeta _replyToIdMeta =
      const VerificationMeta('replyToId');
  @override
  late final GeneratedColumn<String> replyToId = GeneratedColumn<String>(
      'reply_to_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _mediaUrlMeta =
      const VerificationMeta('mediaUrl');
  @override
  late final GeneratedColumn<String> mediaUrl = GeneratedColumn<String>(
      'media_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _thumbnailUrlMeta =
      const VerificationMeta('thumbnailUrl');
  @override
  late final GeneratedColumn<String> thumbnailUrl = GeneratedColumn<String>(
      'thumbnail_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _fileNameMeta =
      const VerificationMeta('fileName');
  @override
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
      'file_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _fileSizeMeta =
      const VerificationMeta('fileSize');
  @override
  late final GeneratedColumn<int> fileSize = GeneratedColumn<int>(
      'file_size', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _mimeTypeMeta =
      const VerificationMeta('mimeType');
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
      'mime_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _durationMeta =
      const VerificationMeta('duration');
  @override
  late final GeneratedColumn<int> duration = GeneratedColumn<int>(
      'duration', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _isEditedMeta =
      const VerificationMeta('isEdited');
  @override
  late final GeneratedColumn<bool> isEdited = GeneratedColumn<bool>(
      'is_edited', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_edited" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _reactionsMeta =
      const VerificationMeta('reactions');
  @override
  late final GeneratedColumn<String> reactions = GeneratedColumn<String>(
      'reactions', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _mediasMeta = const VerificationMeta('medias');
  @override
  late final GeneratedColumn<String> medias = GeneratedColumn<String>(
      'medias', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        conversationId,
        senderRole,
        content,
        timestamp,
        isError,
        status,
        replyToId,
        mediaUrl,
        thumbnailUrl,
        fileName,
        fileSize,
        mimeType,
        duration,
        isEdited,
        reactions,
        medias
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'message_table';
  @override
  VerificationContext validateIntegrity(Insertable<MessageTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('conversation_id')) {
      context.handle(
          _conversationIdMeta,
          conversationId.isAcceptableOrUnknown(
              data['conversation_id']!, _conversationIdMeta));
    } else if (isInserting) {
      context.missing(_conversationIdMeta);
    }
    if (data.containsKey('sender_role')) {
      context.handle(
          _senderRoleMeta,
          senderRole.isAcceptableOrUnknown(
              data['sender_role']!, _senderRoleMeta));
    } else if (isInserting) {
      context.missing(_senderRoleMeta);
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('is_error')) {
      context.handle(_isErrorMeta,
          isError.isAcceptableOrUnknown(data['is_error']!, _isErrorMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('reply_to_id')) {
      context.handle(
          _replyToIdMeta,
          replyToId.isAcceptableOrUnknown(
              data['reply_to_id']!, _replyToIdMeta));
    }
    if (data.containsKey('media_url')) {
      context.handle(_mediaUrlMeta,
          mediaUrl.isAcceptableOrUnknown(data['media_url']!, _mediaUrlMeta));
    }
    if (data.containsKey('thumbnail_url')) {
      context.handle(
          _thumbnailUrlMeta,
          thumbnailUrl.isAcceptableOrUnknown(
              data['thumbnail_url']!, _thumbnailUrlMeta));
    }
    if (data.containsKey('file_name')) {
      context.handle(_fileNameMeta,
          fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta));
    }
    if (data.containsKey('file_size')) {
      context.handle(_fileSizeMeta,
          fileSize.isAcceptableOrUnknown(data['file_size']!, _fileSizeMeta));
    }
    if (data.containsKey('mime_type')) {
      context.handle(_mimeTypeMeta,
          mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta));
    }
    if (data.containsKey('duration')) {
      context.handle(_durationMeta,
          duration.isAcceptableOrUnknown(data['duration']!, _durationMeta));
    }
    if (data.containsKey('is_edited')) {
      context.handle(_isEditedMeta,
          isEdited.isAcceptableOrUnknown(data['is_edited']!, _isEditedMeta));
    }
    if (data.containsKey('reactions')) {
      context.handle(_reactionsMeta,
          reactions.isAcceptableOrUnknown(data['reactions']!, _reactionsMeta));
    }
    if (data.containsKey('medias')) {
      context.handle(_mediasMeta,
          medias.isAcceptableOrUnknown(data['medias']!, _mediasMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MessageTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MessageTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      conversationId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}conversation_id'])!,
      senderRole: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sender_role'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}timestamp'])!,
      isError: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_error'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      replyToId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reply_to_id']),
      mediaUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}media_url']),
      thumbnailUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}thumbnail_url']),
      fileName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}file_name']),
      fileSize: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}file_size']),
      mimeType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mime_type']),
      duration: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration']),
      isEdited: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_edited'])!,
      reactions: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reactions']),
      medias: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}medias']),
    );
  }

  @override
  $MessageTableTable createAlias(String alias) {
    return $MessageTableTable(attachedDatabase, alias);
  }
}

class MessageTableData extends DataClass
    implements Insertable<MessageTableData> {
  /// Message primary key.
  final String id;

  /// Foreign key referencing [ConversationTable.id].
  final String conversationId;
  final String senderRole;
  final String content;
  final DateTime timestamp;
  final bool isError;

  /// Detailed status string: 'sending', 'sent', 'streaming', 'failed'.
  final String status;
  final String? replyToId;
  final String? mediaUrl;
  final String? thumbnailUrl;
  final String? fileName;
  final int? fileSize;
  final String? mimeType;
  final int? duration;
  final bool isEdited;
  final String? reactions;
  final String? medias;
  const MessageTableData(
      {required this.id,
      required this.conversationId,
      required this.senderRole,
      required this.content,
      required this.timestamp,
      required this.isError,
      required this.status,
      this.replyToId,
      this.mediaUrl,
      this.thumbnailUrl,
      this.fileName,
      this.fileSize,
      this.mimeType,
      this.duration,
      required this.isEdited,
      this.reactions,
      this.medias});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['conversation_id'] = Variable<String>(conversationId);
    map['sender_role'] = Variable<String>(senderRole);
    map['content'] = Variable<String>(content);
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['is_error'] = Variable<bool>(isError);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || replyToId != null) {
      map['reply_to_id'] = Variable<String>(replyToId);
    }
    if (!nullToAbsent || mediaUrl != null) {
      map['media_url'] = Variable<String>(mediaUrl);
    }
    if (!nullToAbsent || thumbnailUrl != null) {
      map['thumbnail_url'] = Variable<String>(thumbnailUrl);
    }
    if (!nullToAbsent || fileName != null) {
      map['file_name'] = Variable<String>(fileName);
    }
    if (!nullToAbsent || fileSize != null) {
      map['file_size'] = Variable<int>(fileSize);
    }
    if (!nullToAbsent || mimeType != null) {
      map['mime_type'] = Variable<String>(mimeType);
    }
    if (!nullToAbsent || duration != null) {
      map['duration'] = Variable<int>(duration);
    }
    map['is_edited'] = Variable<bool>(isEdited);
    if (!nullToAbsent || reactions != null) {
      map['reactions'] = Variable<String>(reactions);
    }
    if (!nullToAbsent || medias != null) {
      map['medias'] = Variable<String>(medias);
    }
    return map;
  }

  MessageTableCompanion toCompanion(bool nullToAbsent) {
    return MessageTableCompanion(
      id: Value(id),
      conversationId: Value(conversationId),
      senderRole: Value(senderRole),
      content: Value(content),
      timestamp: Value(timestamp),
      isError: Value(isError),
      status: Value(status),
      replyToId: replyToId == null && nullToAbsent
          ? const Value.absent()
          : Value(replyToId),
      mediaUrl: mediaUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(mediaUrl),
      thumbnailUrl: thumbnailUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailUrl),
      fileName: fileName == null && nullToAbsent
          ? const Value.absent()
          : Value(fileName),
      fileSize: fileSize == null && nullToAbsent
          ? const Value.absent()
          : Value(fileSize),
      mimeType: mimeType == null && nullToAbsent
          ? const Value.absent()
          : Value(mimeType),
      duration: duration == null && nullToAbsent
          ? const Value.absent()
          : Value(duration),
      isEdited: Value(isEdited),
      reactions: reactions == null && nullToAbsent
          ? const Value.absent()
          : Value(reactions),
      medias:
          medias == null && nullToAbsent ? const Value.absent() : Value(medias),
    );
  }

  factory MessageTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MessageTableData(
      id: serializer.fromJson<String>(json['id']),
      conversationId: serializer.fromJson<String>(json['conversationId']),
      senderRole: serializer.fromJson<String>(json['senderRole']),
      content: serializer.fromJson<String>(json['content']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      isError: serializer.fromJson<bool>(json['isError']),
      status: serializer.fromJson<String>(json['status']),
      replyToId: serializer.fromJson<String?>(json['replyToId']),
      mediaUrl: serializer.fromJson<String?>(json['mediaUrl']),
      thumbnailUrl: serializer.fromJson<String?>(json['thumbnailUrl']),
      fileName: serializer.fromJson<String?>(json['fileName']),
      fileSize: serializer.fromJson<int?>(json['fileSize']),
      mimeType: serializer.fromJson<String?>(json['mimeType']),
      duration: serializer.fromJson<int?>(json['duration']),
      isEdited: serializer.fromJson<bool>(json['isEdited']),
      reactions: serializer.fromJson<String?>(json['reactions']),
      medias: serializer.fromJson<String?>(json['medias']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'conversationId': serializer.toJson<String>(conversationId),
      'senderRole': serializer.toJson<String>(senderRole),
      'content': serializer.toJson<String>(content),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'isError': serializer.toJson<bool>(isError),
      'status': serializer.toJson<String>(status),
      'replyToId': serializer.toJson<String?>(replyToId),
      'mediaUrl': serializer.toJson<String?>(mediaUrl),
      'thumbnailUrl': serializer.toJson<String?>(thumbnailUrl),
      'fileName': serializer.toJson<String?>(fileName),
      'fileSize': serializer.toJson<int?>(fileSize),
      'mimeType': serializer.toJson<String?>(mimeType),
      'duration': serializer.toJson<int?>(duration),
      'isEdited': serializer.toJson<bool>(isEdited),
      'reactions': serializer.toJson<String?>(reactions),
      'medias': serializer.toJson<String?>(medias),
    };
  }

  MessageTableData copyWith(
          {String? id,
          String? conversationId,
          String? senderRole,
          String? content,
          DateTime? timestamp,
          bool? isError,
          String? status,
          Value<String?> replyToId = const Value.absent(),
          Value<String?> mediaUrl = const Value.absent(),
          Value<String?> thumbnailUrl = const Value.absent(),
          Value<String?> fileName = const Value.absent(),
          Value<int?> fileSize = const Value.absent(),
          Value<String?> mimeType = const Value.absent(),
          Value<int?> duration = const Value.absent(),
          bool? isEdited,
          Value<String?> reactions = const Value.absent(),
          Value<String?> medias = const Value.absent()}) =>
      MessageTableData(
        id: id ?? this.id,
        conversationId: conversationId ?? this.conversationId,
        senderRole: senderRole ?? this.senderRole,
        content: content ?? this.content,
        timestamp: timestamp ?? this.timestamp,
        isError: isError ?? this.isError,
        status: status ?? this.status,
        replyToId: replyToId.present ? replyToId.value : this.replyToId,
        mediaUrl: mediaUrl.present ? mediaUrl.value : this.mediaUrl,
        thumbnailUrl:
            thumbnailUrl.present ? thumbnailUrl.value : this.thumbnailUrl,
        fileName: fileName.present ? fileName.value : this.fileName,
        fileSize: fileSize.present ? fileSize.value : this.fileSize,
        mimeType: mimeType.present ? mimeType.value : this.mimeType,
        duration: duration.present ? duration.value : this.duration,
        isEdited: isEdited ?? this.isEdited,
        reactions: reactions.present ? reactions.value : this.reactions,
        medias: medias.present ? medias.value : this.medias,
      );
  MessageTableData copyWithCompanion(MessageTableCompanion data) {
    return MessageTableData(
      id: data.id.present ? data.id.value : this.id,
      conversationId: data.conversationId.present
          ? data.conversationId.value
          : this.conversationId,
      senderRole:
          data.senderRole.present ? data.senderRole.value : this.senderRole,
      content: data.content.present ? data.content.value : this.content,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      isError: data.isError.present ? data.isError.value : this.isError,
      status: data.status.present ? data.status.value : this.status,
      replyToId: data.replyToId.present ? data.replyToId.value : this.replyToId,
      mediaUrl: data.mediaUrl.present ? data.mediaUrl.value : this.mediaUrl,
      thumbnailUrl: data.thumbnailUrl.present
          ? data.thumbnailUrl.value
          : this.thumbnailUrl,
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      fileSize: data.fileSize.present ? data.fileSize.value : this.fileSize,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      duration: data.duration.present ? data.duration.value : this.duration,
      isEdited: data.isEdited.present ? data.isEdited.value : this.isEdited,
      reactions: data.reactions.present ? data.reactions.value : this.reactions,
      medias: data.medias.present ? data.medias.value : this.medias,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MessageTableData(')
          ..write('id: $id, ')
          ..write('conversationId: $conversationId, ')
          ..write('senderRole: $senderRole, ')
          ..write('content: $content, ')
          ..write('timestamp: $timestamp, ')
          ..write('isError: $isError, ')
          ..write('status: $status, ')
          ..write('replyToId: $replyToId, ')
          ..write('mediaUrl: $mediaUrl, ')
          ..write('thumbnailUrl: $thumbnailUrl, ')
          ..write('fileName: $fileName, ')
          ..write('fileSize: $fileSize, ')
          ..write('mimeType: $mimeType, ')
          ..write('duration: $duration, ')
          ..write('isEdited: $isEdited, ')
          ..write('reactions: $reactions, ')
          ..write('medias: $medias')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      conversationId,
      senderRole,
      content,
      timestamp,
      isError,
      status,
      replyToId,
      mediaUrl,
      thumbnailUrl,
      fileName,
      fileSize,
      mimeType,
      duration,
      isEdited,
      reactions,
      medias);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MessageTableData &&
          other.id == this.id &&
          other.conversationId == this.conversationId &&
          other.senderRole == this.senderRole &&
          other.content == this.content &&
          other.timestamp == this.timestamp &&
          other.isError == this.isError &&
          other.status == this.status &&
          other.replyToId == this.replyToId &&
          other.mediaUrl == this.mediaUrl &&
          other.thumbnailUrl == this.thumbnailUrl &&
          other.fileName == this.fileName &&
          other.fileSize == this.fileSize &&
          other.mimeType == this.mimeType &&
          other.duration == this.duration &&
          other.isEdited == this.isEdited &&
          other.reactions == this.reactions &&
          other.medias == this.medias);
}

class MessageTableCompanion extends UpdateCompanion<MessageTableData> {
  final Value<String> id;
  final Value<String> conversationId;
  final Value<String> senderRole;
  final Value<String> content;
  final Value<DateTime> timestamp;
  final Value<bool> isError;
  final Value<String> status;
  final Value<String?> replyToId;
  final Value<String?> mediaUrl;
  final Value<String?> thumbnailUrl;
  final Value<String?> fileName;
  final Value<int?> fileSize;
  final Value<String?> mimeType;
  final Value<int?> duration;
  final Value<bool> isEdited;
  final Value<String?> reactions;
  final Value<String?> medias;
  final Value<int> rowid;
  const MessageTableCompanion({
    this.id = const Value.absent(),
    this.conversationId = const Value.absent(),
    this.senderRole = const Value.absent(),
    this.content = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.isError = const Value.absent(),
    this.status = const Value.absent(),
    this.replyToId = const Value.absent(),
    this.mediaUrl = const Value.absent(),
    this.thumbnailUrl = const Value.absent(),
    this.fileName = const Value.absent(),
    this.fileSize = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.duration = const Value.absent(),
    this.isEdited = const Value.absent(),
    this.reactions = const Value.absent(),
    this.medias = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MessageTableCompanion.insert({
    required String id,
    required String conversationId,
    required String senderRole,
    required String content,
    required DateTime timestamp,
    this.isError = const Value.absent(),
    this.status = const Value.absent(),
    this.replyToId = const Value.absent(),
    this.mediaUrl = const Value.absent(),
    this.thumbnailUrl = const Value.absent(),
    this.fileName = const Value.absent(),
    this.fileSize = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.duration = const Value.absent(),
    this.isEdited = const Value.absent(),
    this.reactions = const Value.absent(),
    this.medias = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        conversationId = Value(conversationId),
        senderRole = Value(senderRole),
        content = Value(content),
        timestamp = Value(timestamp);
  static Insertable<MessageTableData> custom({
    Expression<String>? id,
    Expression<String>? conversationId,
    Expression<String>? senderRole,
    Expression<String>? content,
    Expression<DateTime>? timestamp,
    Expression<bool>? isError,
    Expression<String>? status,
    Expression<String>? replyToId,
    Expression<String>? mediaUrl,
    Expression<String>? thumbnailUrl,
    Expression<String>? fileName,
    Expression<int>? fileSize,
    Expression<String>? mimeType,
    Expression<int>? duration,
    Expression<bool>? isEdited,
    Expression<String>? reactions,
    Expression<String>? medias,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (conversationId != null) 'conversation_id': conversationId,
      if (senderRole != null) 'sender_role': senderRole,
      if (content != null) 'content': content,
      if (timestamp != null) 'timestamp': timestamp,
      if (isError != null) 'is_error': isError,
      if (status != null) 'status': status,
      if (replyToId != null) 'reply_to_id': replyToId,
      if (mediaUrl != null) 'media_url': mediaUrl,
      if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
      if (fileName != null) 'file_name': fileName,
      if (fileSize != null) 'file_size': fileSize,
      if (mimeType != null) 'mime_type': mimeType,
      if (duration != null) 'duration': duration,
      if (isEdited != null) 'is_edited': isEdited,
      if (reactions != null) 'reactions': reactions,
      if (medias != null) 'medias': medias,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MessageTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? conversationId,
      Value<String>? senderRole,
      Value<String>? content,
      Value<DateTime>? timestamp,
      Value<bool>? isError,
      Value<String>? status,
      Value<String?>? replyToId,
      Value<String?>? mediaUrl,
      Value<String?>? thumbnailUrl,
      Value<String?>? fileName,
      Value<int?>? fileSize,
      Value<String?>? mimeType,
      Value<int?>? duration,
      Value<bool>? isEdited,
      Value<String?>? reactions,
      Value<String?>? medias,
      Value<int>? rowid}) {
    return MessageTableCompanion(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderRole: senderRole ?? this.senderRole,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isError: isError ?? this.isError,
      status: status ?? this.status,
      replyToId: replyToId ?? this.replyToId,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      mimeType: mimeType ?? this.mimeType,
      duration: duration ?? this.duration,
      isEdited: isEdited ?? this.isEdited,
      reactions: reactions ?? this.reactions,
      medias: medias ?? this.medias,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (conversationId.present) {
      map['conversation_id'] = Variable<String>(conversationId.value);
    }
    if (senderRole.present) {
      map['sender_role'] = Variable<String>(senderRole.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (isError.present) {
      map['is_error'] = Variable<bool>(isError.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (replyToId.present) {
      map['reply_to_id'] = Variable<String>(replyToId.value);
    }
    if (mediaUrl.present) {
      map['media_url'] = Variable<String>(mediaUrl.value);
    }
    if (thumbnailUrl.present) {
      map['thumbnail_url'] = Variable<String>(thumbnailUrl.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (fileSize.present) {
      map['file_size'] = Variable<int>(fileSize.value);
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (duration.present) {
      map['duration'] = Variable<int>(duration.value);
    }
    if (isEdited.present) {
      map['is_edited'] = Variable<bool>(isEdited.value);
    }
    if (reactions.present) {
      map['reactions'] = Variable<String>(reactions.value);
    }
    if (medias.present) {
      map['medias'] = Variable<String>(medias.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessageTableCompanion(')
          ..write('id: $id, ')
          ..write('conversationId: $conversationId, ')
          ..write('senderRole: $senderRole, ')
          ..write('content: $content, ')
          ..write('timestamp: $timestamp, ')
          ..write('isError: $isError, ')
          ..write('status: $status, ')
          ..write('replyToId: $replyToId, ')
          ..write('mediaUrl: $mediaUrl, ')
          ..write('thumbnailUrl: $thumbnailUrl, ')
          ..write('fileName: $fileName, ')
          ..write('fileSize: $fileSize, ')
          ..write('mimeType: $mimeType, ')
          ..write('duration: $duration, ')
          ..write('isEdited: $isEdited, ')
          ..write('reactions: $reactions, ')
          ..write('medias: $medias, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTableTable extends AppSettingsTable
    with TableInfo<$AppSettingsTableTable, AppSettingsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _themeModeMeta =
      const VerificationMeta('themeMode');
  @override
  late final GeneratedColumn<String> themeMode = GeneratedColumn<String>(
      'theme_mode', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('dark'));
  static const VerificationMeta _languageCodeMeta =
      const VerificationMeta('languageCode');
  @override
  late final GeneratedColumn<String> languageCode = GeneratedColumn<String>(
      'language_code', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('en'));
  static const VerificationMeta _activeAiProviderMeta =
      const VerificationMeta('activeAiProvider');
  @override
  late final GeneratedColumn<String> activeAiProvider = GeneratedColumn<String>(
      'active_ai_provider', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('mock'));
  static const VerificationMeta _activeAiModelMeta =
      const VerificationMeta('activeAiModel');
  @override
  late final GeneratedColumn<String> activeAiModel = GeneratedColumn<String>(
      'active_ai_model', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('gemini-1.5-flash'));
  static const VerificationMeta _geminiApiKeyMeta =
      const VerificationMeta('geminiApiKey');
  @override
  late final GeneratedColumn<String> geminiApiKey = GeneratedColumn<String>(
      'gemini_api_key', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _localLlmBaseUrlMeta =
      const VerificationMeta('localLlmBaseUrl');
  @override
  late final GeneratedColumn<String> localLlmBaseUrl = GeneratedColumn<String>(
      'local_llm_base_url', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('http://localhost:11434'));
  static const VerificationMeta _systemPromptMeta =
      const VerificationMeta('systemPrompt');
  @override
  late final GeneratedColumn<String> systemPrompt = GeneratedColumn<String>(
      'system_prompt', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('You are a helpful, expert AI assistant.'));
  static const VerificationMeta _accessTokenMeta =
      const VerificationMeta('accessToken');
  @override
  late final GeneratedColumn<String> accessToken = GeneratedColumn<String>(
      'access_token', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _refreshTokenMeta =
      const VerificationMeta('refreshToken');
  @override
  late final GeneratedColumn<String> refreshToken = GeneratedColumn<String>(
      'refresh_token', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _serverHostMeta =
      const VerificationMeta('serverHost');
  @override
  late final GeneratedColumn<String> serverHost = GeneratedColumn<String>(
      'server_host', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(AppConfig.defaultServerHost));
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _usernameMeta =
      const VerificationMeta('username');
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
      'username', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        themeMode,
        languageCode,
        activeAiProvider,
        activeAiModel,
        geminiApiKey,
        localLlmBaseUrl,
        systemPrompt,
        accessToken,
        refreshToken,
        serverHost,
        userId,
        username,
        email
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<AppSettingsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('theme_mode')) {
      context.handle(_themeModeMeta,
          themeMode.isAcceptableOrUnknown(data['theme_mode']!, _themeModeMeta));
    }
    if (data.containsKey('language_code')) {
      context.handle(
          _languageCodeMeta,
          languageCode.isAcceptableOrUnknown(
              data['language_code']!, _languageCodeMeta));
    }
    if (data.containsKey('active_ai_provider')) {
      context.handle(
          _activeAiProviderMeta,
          activeAiProvider.isAcceptableOrUnknown(
              data['active_ai_provider']!, _activeAiProviderMeta));
    }
    if (data.containsKey('active_ai_model')) {
      context.handle(
          _activeAiModelMeta,
          activeAiModel.isAcceptableOrUnknown(
              data['active_ai_model']!, _activeAiModelMeta));
    }
    if (data.containsKey('gemini_api_key')) {
      context.handle(
          _geminiApiKeyMeta,
          geminiApiKey.isAcceptableOrUnknown(
              data['gemini_api_key']!, _geminiApiKeyMeta));
    }
    if (data.containsKey('local_llm_base_url')) {
      context.handle(
          _localLlmBaseUrlMeta,
          localLlmBaseUrl.isAcceptableOrUnknown(
              data['local_llm_base_url']!, _localLlmBaseUrlMeta));
    }
    if (data.containsKey('system_prompt')) {
      context.handle(
          _systemPromptMeta,
          systemPrompt.isAcceptableOrUnknown(
              data['system_prompt']!, _systemPromptMeta));
    }
    if (data.containsKey('access_token')) {
      context.handle(
          _accessTokenMeta,
          accessToken.isAcceptableOrUnknown(
              data['access_token']!, _accessTokenMeta));
    }
    if (data.containsKey('refresh_token')) {
      context.handle(
          _refreshTokenMeta,
          refreshToken.isAcceptableOrUnknown(
              data['refresh_token']!, _refreshTokenMeta));
    }
    if (data.containsKey('server_host')) {
      context.handle(
          _serverHostMeta,
          serverHost.isAcceptableOrUnknown(
              data['server_host']!, _serverHostMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    }
    if (data.containsKey('username')) {
      context.handle(_usernameMeta,
          username.isAcceptableOrUnknown(data['username']!, _usernameMeta));
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppSettingsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSettingsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      themeMode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}theme_mode'])!,
      languageCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}language_code'])!,
      activeAiProvider: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}active_ai_provider'])!,
      activeAiModel: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}active_ai_model'])!,
      geminiApiKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}gemini_api_key'])!,
      localLlmBaseUrl: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}local_llm_base_url'])!,
      systemPrompt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}system_prompt'])!,
      accessToken: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}access_token'])!,
      refreshToken: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}refresh_token'])!,
      serverHost: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}server_host'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      username: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}username'])!,
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email'])!,
    );
  }

  @override
  $AppSettingsTableTable createAlias(String alias) {
    return $AppSettingsTableTable(attachedDatabase, alias);
  }
}

class AppSettingsTableData extends DataClass
    implements Insertable<AppSettingsTableData> {
  /// Key for setting entry (e.g., 'singleton').
  final String id;

  /// Theme mode string ('light', 'dark', 'sepia').
  final String themeMode;

  /// Locale language code ('en', 'vi').
  final String languageCode;

  /// Currently active AI Provider ('mock', 'gemini', 'local').
  final String activeAiProvider;

  /// Currently active AI Model name.
  final String activeAiModel;

  /// Google AI Studio API Key.
  final String geminiApiKey;

  /// Local LLM Base URL (e.g. Ollama http://localhost:11434).
  final String localLlmBaseUrl;

  /// Default system prompt.
  final String systemPrompt;

  /// Access Token for REST & WebSockets auth.
  final String accessToken;

  /// Refresh Token for RTR auth flow.
  final String refreshToken;

  /// Rust backend server host base URL.
  final String serverHost;

  /// Persistent logged-in user ID.
  final String userId;

  /// Persistent logged-in username.
  final String username;

  /// Persistent logged-in email.
  final String email;
  const AppSettingsTableData(
      {required this.id,
      required this.themeMode,
      required this.languageCode,
      required this.activeAiProvider,
      required this.activeAiModel,
      required this.geminiApiKey,
      required this.localLlmBaseUrl,
      required this.systemPrompt,
      required this.accessToken,
      required this.refreshToken,
      required this.serverHost,
      required this.userId,
      required this.username,
      required this.email});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['theme_mode'] = Variable<String>(themeMode);
    map['language_code'] = Variable<String>(languageCode);
    map['active_ai_provider'] = Variable<String>(activeAiProvider);
    map['active_ai_model'] = Variable<String>(activeAiModel);
    map['gemini_api_key'] = Variable<String>(geminiApiKey);
    map['local_llm_base_url'] = Variable<String>(localLlmBaseUrl);
    map['system_prompt'] = Variable<String>(systemPrompt);
    map['access_token'] = Variable<String>(accessToken);
    map['refresh_token'] = Variable<String>(refreshToken);
    map['server_host'] = Variable<String>(serverHost);
    map['user_id'] = Variable<String>(userId);
    map['username'] = Variable<String>(username);
    map['email'] = Variable<String>(email);
    return map;
  }

  AppSettingsTableCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsTableCompanion(
      id: Value(id),
      themeMode: Value(themeMode),
      languageCode: Value(languageCode),
      activeAiProvider: Value(activeAiProvider),
      activeAiModel: Value(activeAiModel),
      geminiApiKey: Value(geminiApiKey),
      localLlmBaseUrl: Value(localLlmBaseUrl),
      systemPrompt: Value(systemPrompt),
      accessToken: Value(accessToken),
      refreshToken: Value(refreshToken),
      serverHost: Value(serverHost),
      userId: Value(userId),
      username: Value(username),
      email: Value(email),
    );
  }

  factory AppSettingsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSettingsTableData(
      id: serializer.fromJson<String>(json['id']),
      themeMode: serializer.fromJson<String>(json['themeMode']),
      languageCode: serializer.fromJson<String>(json['languageCode']),
      activeAiProvider: serializer.fromJson<String>(json['activeAiProvider']),
      activeAiModel: serializer.fromJson<String>(json['activeAiModel']),
      geminiApiKey: serializer.fromJson<String>(json['geminiApiKey']),
      localLlmBaseUrl: serializer.fromJson<String>(json['localLlmBaseUrl']),
      systemPrompt: serializer.fromJson<String>(json['systemPrompt']),
      accessToken: serializer.fromJson<String>(json['accessToken']),
      refreshToken: serializer.fromJson<String>(json['refreshToken']),
      serverHost: serializer.fromJson<String>(json['serverHost']),
      userId: serializer.fromJson<String>(json['userId']),
      username: serializer.fromJson<String>(json['username']),
      email: serializer.fromJson<String>(json['email']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'themeMode': serializer.toJson<String>(themeMode),
      'languageCode': serializer.toJson<String>(languageCode),
      'activeAiProvider': serializer.toJson<String>(activeAiProvider),
      'activeAiModel': serializer.toJson<String>(activeAiModel),
      'geminiApiKey': serializer.toJson<String>(geminiApiKey),
      'localLlmBaseUrl': serializer.toJson<String>(localLlmBaseUrl),
      'systemPrompt': serializer.toJson<String>(systemPrompt),
      'accessToken': serializer.toJson<String>(accessToken),
      'refreshToken': serializer.toJson<String>(refreshToken),
      'serverHost': serializer.toJson<String>(serverHost),
      'userId': serializer.toJson<String>(userId),
      'username': serializer.toJson<String>(username),
      'email': serializer.toJson<String>(email),
    };
  }

  AppSettingsTableData copyWith(
          {String? id,
          String? themeMode,
          String? languageCode,
          String? activeAiProvider,
          String? activeAiModel,
          String? geminiApiKey,
          String? localLlmBaseUrl,
          String? systemPrompt,
          String? accessToken,
          String? refreshToken,
          String? serverHost,
          String? userId,
          String? username,
          String? email}) =>
      AppSettingsTableData(
        id: id ?? this.id,
        themeMode: themeMode ?? this.themeMode,
        languageCode: languageCode ?? this.languageCode,
        activeAiProvider: activeAiProvider ?? this.activeAiProvider,
        activeAiModel: activeAiModel ?? this.activeAiModel,
        geminiApiKey: geminiApiKey ?? this.geminiApiKey,
        localLlmBaseUrl: localLlmBaseUrl ?? this.localLlmBaseUrl,
        systemPrompt: systemPrompt ?? this.systemPrompt,
        accessToken: accessToken ?? this.accessToken,
        refreshToken: refreshToken ?? this.refreshToken,
        serverHost: serverHost ?? this.serverHost,
        userId: userId ?? this.userId,
        username: username ?? this.username,
        email: email ?? this.email,
      );
  AppSettingsTableData copyWithCompanion(AppSettingsTableCompanion data) {
    return AppSettingsTableData(
      id: data.id.present ? data.id.value : this.id,
      themeMode: data.themeMode.present ? data.themeMode.value : this.themeMode,
      languageCode: data.languageCode.present
          ? data.languageCode.value
          : this.languageCode,
      activeAiProvider: data.activeAiProvider.present
          ? data.activeAiProvider.value
          : this.activeAiProvider,
      activeAiModel: data.activeAiModel.present
          ? data.activeAiModel.value
          : this.activeAiModel,
      geminiApiKey: data.geminiApiKey.present
          ? data.geminiApiKey.value
          : this.geminiApiKey,
      localLlmBaseUrl: data.localLlmBaseUrl.present
          ? data.localLlmBaseUrl.value
          : this.localLlmBaseUrl,
      systemPrompt: data.systemPrompt.present
          ? data.systemPrompt.value
          : this.systemPrompt,
      accessToken:
          data.accessToken.present ? data.accessToken.value : this.accessToken,
      refreshToken: data.refreshToken.present
          ? data.refreshToken.value
          : this.refreshToken,
      serverHost:
          data.serverHost.present ? data.serverHost.value : this.serverHost,
      userId: data.userId.present ? data.userId.value : this.userId,
      username: data.username.present ? data.username.value : this.username,
      email: data.email.present ? data.email.value : this.email,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsTableData(')
          ..write('id: $id, ')
          ..write('themeMode: $themeMode, ')
          ..write('languageCode: $languageCode, ')
          ..write('activeAiProvider: $activeAiProvider, ')
          ..write('activeAiModel: $activeAiModel, ')
          ..write('geminiApiKey: $geminiApiKey, ')
          ..write('localLlmBaseUrl: $localLlmBaseUrl, ')
          ..write('systemPrompt: $systemPrompt, ')
          ..write('accessToken: $accessToken, ')
          ..write('refreshToken: $refreshToken, ')
          ..write('serverHost: $serverHost, ')
          ..write('userId: $userId, ')
          ..write('username: $username, ')
          ..write('email: $email')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      themeMode,
      languageCode,
      activeAiProvider,
      activeAiModel,
      geminiApiKey,
      localLlmBaseUrl,
      systemPrompt,
      accessToken,
      refreshToken,
      serverHost,
      userId,
      username,
      email);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSettingsTableData &&
          other.id == this.id &&
          other.themeMode == this.themeMode &&
          other.languageCode == this.languageCode &&
          other.activeAiProvider == this.activeAiProvider &&
          other.activeAiModel == this.activeAiModel &&
          other.geminiApiKey == this.geminiApiKey &&
          other.localLlmBaseUrl == this.localLlmBaseUrl &&
          other.systemPrompt == this.systemPrompt &&
          other.accessToken == this.accessToken &&
          other.refreshToken == this.refreshToken &&
          other.serverHost == this.serverHost &&
          other.userId == this.userId &&
          other.username == this.username &&
          other.email == this.email);
}

class AppSettingsTableCompanion extends UpdateCompanion<AppSettingsTableData> {
  final Value<String> id;
  final Value<String> themeMode;
  final Value<String> languageCode;
  final Value<String> activeAiProvider;
  final Value<String> activeAiModel;
  final Value<String> geminiApiKey;
  final Value<String> localLlmBaseUrl;
  final Value<String> systemPrompt;
  final Value<String> accessToken;
  final Value<String> refreshToken;
  final Value<String> serverHost;
  final Value<String> userId;
  final Value<String> username;
  final Value<String> email;
  final Value<int> rowid;
  const AppSettingsTableCompanion({
    this.id = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.languageCode = const Value.absent(),
    this.activeAiProvider = const Value.absent(),
    this.activeAiModel = const Value.absent(),
    this.geminiApiKey = const Value.absent(),
    this.localLlmBaseUrl = const Value.absent(),
    this.systemPrompt = const Value.absent(),
    this.accessToken = const Value.absent(),
    this.refreshToken = const Value.absent(),
    this.serverHost = const Value.absent(),
    this.userId = const Value.absent(),
    this.username = const Value.absent(),
    this.email = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsTableCompanion.insert({
    required String id,
    this.themeMode = const Value.absent(),
    this.languageCode = const Value.absent(),
    this.activeAiProvider = const Value.absent(),
    this.activeAiModel = const Value.absent(),
    this.geminiApiKey = const Value.absent(),
    this.localLlmBaseUrl = const Value.absent(),
    this.systemPrompt = const Value.absent(),
    this.accessToken = const Value.absent(),
    this.refreshToken = const Value.absent(),
    this.serverHost = const Value.absent(),
    this.userId = const Value.absent(),
    this.username = const Value.absent(),
    this.email = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<AppSettingsTableData> custom({
    Expression<String>? id,
    Expression<String>? themeMode,
    Expression<String>? languageCode,
    Expression<String>? activeAiProvider,
    Expression<String>? activeAiModel,
    Expression<String>? geminiApiKey,
    Expression<String>? localLlmBaseUrl,
    Expression<String>? systemPrompt,
    Expression<String>? accessToken,
    Expression<String>? refreshToken,
    Expression<String>? serverHost,
    Expression<String>? userId,
    Expression<String>? username,
    Expression<String>? email,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (themeMode != null) 'theme_mode': themeMode,
      if (languageCode != null) 'language_code': languageCode,
      if (activeAiProvider != null) 'active_ai_provider': activeAiProvider,
      if (activeAiModel != null) 'active_ai_model': activeAiModel,
      if (geminiApiKey != null) 'gemini_api_key': geminiApiKey,
      if (localLlmBaseUrl != null) 'local_llm_base_url': localLlmBaseUrl,
      if (systemPrompt != null) 'system_prompt': systemPrompt,
      if (accessToken != null) 'access_token': accessToken,
      if (refreshToken != null) 'refresh_token': refreshToken,
      if (serverHost != null) 'server_host': serverHost,
      if (userId != null) 'user_id': userId,
      if (username != null) 'username': username,
      if (email != null) 'email': email,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? themeMode,
      Value<String>? languageCode,
      Value<String>? activeAiProvider,
      Value<String>? activeAiModel,
      Value<String>? geminiApiKey,
      Value<String>? localLlmBaseUrl,
      Value<String>? systemPrompt,
      Value<String>? accessToken,
      Value<String>? refreshToken,
      Value<String>? serverHost,
      Value<String>? userId,
      Value<String>? username,
      Value<String>? email,
      Value<int>? rowid}) {
    return AppSettingsTableCompanion(
      id: id ?? this.id,
      themeMode: themeMode ?? this.themeMode,
      languageCode: languageCode ?? this.languageCode,
      activeAiProvider: activeAiProvider ?? this.activeAiProvider,
      activeAiModel: activeAiModel ?? this.activeAiModel,
      geminiApiKey: geminiApiKey ?? this.geminiApiKey,
      localLlmBaseUrl: localLlmBaseUrl ?? this.localLlmBaseUrl,
      systemPrompt: systemPrompt ?? this.systemPrompt,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      serverHost: serverHost ?? this.serverHost,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      email: email ?? this.email,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (themeMode.present) {
      map['theme_mode'] = Variable<String>(themeMode.value);
    }
    if (languageCode.present) {
      map['language_code'] = Variable<String>(languageCode.value);
    }
    if (activeAiProvider.present) {
      map['active_ai_provider'] = Variable<String>(activeAiProvider.value);
    }
    if (activeAiModel.present) {
      map['active_ai_model'] = Variable<String>(activeAiModel.value);
    }
    if (geminiApiKey.present) {
      map['gemini_api_key'] = Variable<String>(geminiApiKey.value);
    }
    if (localLlmBaseUrl.present) {
      map['local_llm_base_url'] = Variable<String>(localLlmBaseUrl.value);
    }
    if (systemPrompt.present) {
      map['system_prompt'] = Variable<String>(systemPrompt.value);
    }
    if (accessToken.present) {
      map['access_token'] = Variable<String>(accessToken.value);
    }
    if (refreshToken.present) {
      map['refresh_token'] = Variable<String>(refreshToken.value);
    }
    if (serverHost.present) {
      map['server_host'] = Variable<String>(serverHost.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsTableCompanion(')
          ..write('id: $id, ')
          ..write('themeMode: $themeMode, ')
          ..write('languageCode: $languageCode, ')
          ..write('activeAiProvider: $activeAiProvider, ')
          ..write('activeAiModel: $activeAiModel, ')
          ..write('geminiApiKey: $geminiApiKey, ')
          ..write('localLlmBaseUrl: $localLlmBaseUrl, ')
          ..write('systemPrompt: $systemPrompt, ')
          ..write('accessToken: $accessToken, ')
          ..write('refreshToken: $refreshToken, ')
          ..write('serverHost: $serverHost, ')
          ..write('userId: $userId, ')
          ..write('username: $username, ')
          ..write('email: $email, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ConversationTableTable conversationTable =
      $ConversationTableTable(this);
  late final $MessageTableTable messageTable = $MessageTableTable(this);
  late final $AppSettingsTableTable appSettingsTable =
      $AppSettingsTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [conversationTable, messageTable, appSettingsTable];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('conversation_table',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('message_table', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}

typedef $$ConversationTableTableCreateCompanionBuilder
    = ConversationTableCompanion Function({
  required String id,
  required String title,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<bool> isPinned,
  Value<bool> isFavourite,
  Value<String> modelName,
  Value<String?> draftMessage,
  Value<String?> systemPrompt,
  Value<bool> isUserToUser,
  Value<String> peerId,
  Value<int> rowid,
});
typedef $$ConversationTableTableUpdateCompanionBuilder
    = ConversationTableCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isPinned,
  Value<bool> isFavourite,
  Value<String> modelName,
  Value<String?> draftMessage,
  Value<String?> systemPrompt,
  Value<bool> isUserToUser,
  Value<String> peerId,
  Value<int> rowid,
});

final class $$ConversationTableTableReferences extends BaseReferences<
    _$AppDatabase, $ConversationTableTable, ConversationTableData> {
  $$ConversationTableTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$MessageTableTable, List<MessageTableData>>
      _messageTableRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.messageTable,
              aliasName: $_aliasNameGenerator(
                  db.conversationTable.id, db.messageTable.conversationId));

  $$MessageTableTableProcessedTableManager get messageTableRefs {
    final manager = $$MessageTableTableTableManager($_db, $_db.messageTable)
        .filter(
            (f) => f.conversationId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_messageTableRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ConversationTableTableFilterComposer
    extends Composer<_$AppDatabase, $ConversationTableTable> {
  $$ConversationTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isPinned => $composableBuilder(
      column: $table.isPinned, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isFavourite => $composableBuilder(
      column: $table.isFavourite, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get modelName => $composableBuilder(
      column: $table.modelName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get draftMessage => $composableBuilder(
      column: $table.draftMessage, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get systemPrompt => $composableBuilder(
      column: $table.systemPrompt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isUserToUser => $composableBuilder(
      column: $table.isUserToUser, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get peerId => $composableBuilder(
      column: $table.peerId, builder: (column) => ColumnFilters(column));

  Expression<bool> messageTableRefs(
      Expression<bool> Function($$MessageTableTableFilterComposer f) f) {
    final $$MessageTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.messageTable,
        getReferencedColumn: (t) => t.conversationId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MessageTableTableFilterComposer(
              $db: $db,
              $table: $db.messageTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ConversationTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ConversationTableTable> {
  $$ConversationTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isPinned => $composableBuilder(
      column: $table.isPinned, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isFavourite => $composableBuilder(
      column: $table.isFavourite, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get modelName => $composableBuilder(
      column: $table.modelName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get draftMessage => $composableBuilder(
      column: $table.draftMessage,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get systemPrompt => $composableBuilder(
      column: $table.systemPrompt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isUserToUser => $composableBuilder(
      column: $table.isUserToUser,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get peerId => $composableBuilder(
      column: $table.peerId, builder: (column) => ColumnOrderings(column));
}

class $$ConversationTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConversationTableTable> {
  $$ConversationTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isPinned =>
      $composableBuilder(column: $table.isPinned, builder: (column) => column);

  GeneratedColumn<bool> get isFavourite => $composableBuilder(
      column: $table.isFavourite, builder: (column) => column);

  GeneratedColumn<String> get modelName =>
      $composableBuilder(column: $table.modelName, builder: (column) => column);

  GeneratedColumn<String> get draftMessage => $composableBuilder(
      column: $table.draftMessage, builder: (column) => column);

  GeneratedColumn<String> get systemPrompt => $composableBuilder(
      column: $table.systemPrompt, builder: (column) => column);

  GeneratedColumn<bool> get isUserToUser => $composableBuilder(
      column: $table.isUserToUser, builder: (column) => column);

  GeneratedColumn<String> get peerId =>
      $composableBuilder(column: $table.peerId, builder: (column) => column);

  Expression<T> messageTableRefs<T extends Object>(
      Expression<T> Function($$MessageTableTableAnnotationComposer a) f) {
    final $$MessageTableTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.messageTable,
        getReferencedColumn: (t) => t.conversationId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MessageTableTableAnnotationComposer(
              $db: $db,
              $table: $db.messageTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ConversationTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ConversationTableTable,
    ConversationTableData,
    $$ConversationTableTableFilterComposer,
    $$ConversationTableTableOrderingComposer,
    $$ConversationTableTableAnnotationComposer,
    $$ConversationTableTableCreateCompanionBuilder,
    $$ConversationTableTableUpdateCompanionBuilder,
    (ConversationTableData, $$ConversationTableTableReferences),
    ConversationTableData,
    PrefetchHooks Function({bool messageTableRefs})> {
  $$ConversationTableTableTableManager(
      _$AppDatabase db, $ConversationTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConversationTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConversationTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConversationTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isPinned = const Value.absent(),
            Value<bool> isFavourite = const Value.absent(),
            Value<String> modelName = const Value.absent(),
            Value<String?> draftMessage = const Value.absent(),
            Value<String?> systemPrompt = const Value.absent(),
            Value<bool> isUserToUser = const Value.absent(),
            Value<String> peerId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ConversationTableCompanion(
            id: id,
            title: title,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isPinned: isPinned,
            isFavourite: isFavourite,
            modelName: modelName,
            draftMessage: draftMessage,
            systemPrompt: systemPrompt,
            isUserToUser: isUserToUser,
            peerId: peerId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String title,
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<bool> isPinned = const Value.absent(),
            Value<bool> isFavourite = const Value.absent(),
            Value<String> modelName = const Value.absent(),
            Value<String?> draftMessage = const Value.absent(),
            Value<String?> systemPrompt = const Value.absent(),
            Value<bool> isUserToUser = const Value.absent(),
            Value<String> peerId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ConversationTableCompanion.insert(
            id: id,
            title: title,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isPinned: isPinned,
            isFavourite: isFavourite,
            modelName: modelName,
            draftMessage: draftMessage,
            systemPrompt: systemPrompt,
            isUserToUser: isUserToUser,
            peerId: peerId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ConversationTableTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({messageTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (messageTableRefs) db.messageTable],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (messageTableRefs)
                    await $_getPrefetchedData<ConversationTableData,
                            $ConversationTableTable, MessageTableData>(
                        currentTable: table,
                        referencedTable: $$ConversationTableTableReferences
                            ._messageTableRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ConversationTableTableReferences(db, table, p0)
                                .messageTableRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.conversationId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ConversationTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ConversationTableTable,
    ConversationTableData,
    $$ConversationTableTableFilterComposer,
    $$ConversationTableTableOrderingComposer,
    $$ConversationTableTableAnnotationComposer,
    $$ConversationTableTableCreateCompanionBuilder,
    $$ConversationTableTableUpdateCompanionBuilder,
    (ConversationTableData, $$ConversationTableTableReferences),
    ConversationTableData,
    PrefetchHooks Function({bool messageTableRefs})>;
typedef $$MessageTableTableCreateCompanionBuilder = MessageTableCompanion
    Function({
  required String id,
  required String conversationId,
  required String senderRole,
  required String content,
  required DateTime timestamp,
  Value<bool> isError,
  Value<String> status,
  Value<String?> replyToId,
  Value<String?> mediaUrl,
  Value<String?> thumbnailUrl,
  Value<String?> fileName,
  Value<int?> fileSize,
  Value<String?> mimeType,
  Value<int?> duration,
  Value<bool> isEdited,
  Value<String?> reactions,
  Value<String?> medias,
  Value<int> rowid,
});
typedef $$MessageTableTableUpdateCompanionBuilder = MessageTableCompanion
    Function({
  Value<String> id,
  Value<String> conversationId,
  Value<String> senderRole,
  Value<String> content,
  Value<DateTime> timestamp,
  Value<bool> isError,
  Value<String> status,
  Value<String?> replyToId,
  Value<String?> mediaUrl,
  Value<String?> thumbnailUrl,
  Value<String?> fileName,
  Value<int?> fileSize,
  Value<String?> mimeType,
  Value<int?> duration,
  Value<bool> isEdited,
  Value<String?> reactions,
  Value<String?> medias,
  Value<int> rowid,
});

final class $$MessageTableTableReferences extends BaseReferences<_$AppDatabase,
    $MessageTableTable, MessageTableData> {
  $$MessageTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ConversationTableTable _conversationIdTable(_$AppDatabase db) =>
      db.conversationTable.createAlias($_aliasNameGenerator(
          db.messageTable.conversationId, db.conversationTable.id));

  $$ConversationTableTableProcessedTableManager get conversationId {
    final $_column = $_itemColumn<String>('conversation_id')!;

    final manager =
        $$ConversationTableTableTableManager($_db, $_db.conversationTable)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_conversationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$MessageTableTableFilterComposer
    extends Composer<_$AppDatabase, $MessageTableTable> {
  $$MessageTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get senderRole => $composableBuilder(
      column: $table.senderRole, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isError => $composableBuilder(
      column: $table.isError, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get replyToId => $composableBuilder(
      column: $table.replyToId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mediaUrl => $composableBuilder(
      column: $table.mediaUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get thumbnailUrl => $composableBuilder(
      column: $table.thumbnailUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fileName => $composableBuilder(
      column: $table.fileName, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get fileSize => $composableBuilder(
      column: $table.fileSize, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mimeType => $composableBuilder(
      column: $table.mimeType, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get duration => $composableBuilder(
      column: $table.duration, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isEdited => $composableBuilder(
      column: $table.isEdited, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reactions => $composableBuilder(
      column: $table.reactions, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get medias => $composableBuilder(
      column: $table.medias, builder: (column) => ColumnFilters(column));

  $$ConversationTableTableFilterComposer get conversationId {
    final $$ConversationTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.conversationId,
        referencedTable: $db.conversationTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ConversationTableTableFilterComposer(
              $db: $db,
              $table: $db.conversationTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MessageTableTableOrderingComposer
    extends Composer<_$AppDatabase, $MessageTableTable> {
  $$MessageTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get senderRole => $composableBuilder(
      column: $table.senderRole, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isError => $composableBuilder(
      column: $table.isError, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get replyToId => $composableBuilder(
      column: $table.replyToId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mediaUrl => $composableBuilder(
      column: $table.mediaUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get thumbnailUrl => $composableBuilder(
      column: $table.thumbnailUrl,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fileName => $composableBuilder(
      column: $table.fileName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get fileSize => $composableBuilder(
      column: $table.fileSize, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mimeType => $composableBuilder(
      column: $table.mimeType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get duration => $composableBuilder(
      column: $table.duration, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isEdited => $composableBuilder(
      column: $table.isEdited, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reactions => $composableBuilder(
      column: $table.reactions, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get medias => $composableBuilder(
      column: $table.medias, builder: (column) => ColumnOrderings(column));

  $$ConversationTableTableOrderingComposer get conversationId {
    final $$ConversationTableTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.conversationId,
        referencedTable: $db.conversationTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ConversationTableTableOrderingComposer(
              $db: $db,
              $table: $db.conversationTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MessageTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $MessageTableTable> {
  $$MessageTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get senderRole => $composableBuilder(
      column: $table.senderRole, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<bool> get isError =>
      $composableBuilder(column: $table.isError, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get replyToId =>
      $composableBuilder(column: $table.replyToId, builder: (column) => column);

  GeneratedColumn<String> get mediaUrl =>
      $composableBuilder(column: $table.mediaUrl, builder: (column) => column);

  GeneratedColumn<String> get thumbnailUrl => $composableBuilder(
      column: $table.thumbnailUrl, builder: (column) => column);

  GeneratedColumn<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumn<int> get fileSize =>
      $composableBuilder(column: $table.fileSize, builder: (column) => column);

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);

  GeneratedColumn<int> get duration =>
      $composableBuilder(column: $table.duration, builder: (column) => column);

  GeneratedColumn<bool> get isEdited =>
      $composableBuilder(column: $table.isEdited, builder: (column) => column);

  GeneratedColumn<String> get reactions =>
      $composableBuilder(column: $table.reactions, builder: (column) => column);

  GeneratedColumn<String> get medias =>
      $composableBuilder(column: $table.medias, builder: (column) => column);

  $$ConversationTableTableAnnotationComposer get conversationId {
    final $$ConversationTableTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.conversationId,
            referencedTable: $db.conversationTable,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$ConversationTableTableAnnotationComposer(
                  $db: $db,
                  $table: $db.conversationTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }
}

class $$MessageTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MessageTableTable,
    MessageTableData,
    $$MessageTableTableFilterComposer,
    $$MessageTableTableOrderingComposer,
    $$MessageTableTableAnnotationComposer,
    $$MessageTableTableCreateCompanionBuilder,
    $$MessageTableTableUpdateCompanionBuilder,
    (MessageTableData, $$MessageTableTableReferences),
    MessageTableData,
    PrefetchHooks Function({bool conversationId})> {
  $$MessageTableTableTableManager(_$AppDatabase db, $MessageTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MessageTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MessageTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MessageTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> conversationId = const Value.absent(),
            Value<String> senderRole = const Value.absent(),
            Value<String> content = const Value.absent(),
            Value<DateTime> timestamp = const Value.absent(),
            Value<bool> isError = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> replyToId = const Value.absent(),
            Value<String?> mediaUrl = const Value.absent(),
            Value<String?> thumbnailUrl = const Value.absent(),
            Value<String?> fileName = const Value.absent(),
            Value<int?> fileSize = const Value.absent(),
            Value<String?> mimeType = const Value.absent(),
            Value<int?> duration = const Value.absent(),
            Value<bool> isEdited = const Value.absent(),
            Value<String?> reactions = const Value.absent(),
            Value<String?> medias = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MessageTableCompanion(
            id: id,
            conversationId: conversationId,
            senderRole: senderRole,
            content: content,
            timestamp: timestamp,
            isError: isError,
            status: status,
            replyToId: replyToId,
            mediaUrl: mediaUrl,
            thumbnailUrl: thumbnailUrl,
            fileName: fileName,
            fileSize: fileSize,
            mimeType: mimeType,
            duration: duration,
            isEdited: isEdited,
            reactions: reactions,
            medias: medias,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String conversationId,
            required String senderRole,
            required String content,
            required DateTime timestamp,
            Value<bool> isError = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> replyToId = const Value.absent(),
            Value<String?> mediaUrl = const Value.absent(),
            Value<String?> thumbnailUrl = const Value.absent(),
            Value<String?> fileName = const Value.absent(),
            Value<int?> fileSize = const Value.absent(),
            Value<String?> mimeType = const Value.absent(),
            Value<int?> duration = const Value.absent(),
            Value<bool> isEdited = const Value.absent(),
            Value<String?> reactions = const Value.absent(),
            Value<String?> medias = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MessageTableCompanion.insert(
            id: id,
            conversationId: conversationId,
            senderRole: senderRole,
            content: content,
            timestamp: timestamp,
            isError: isError,
            status: status,
            replyToId: replyToId,
            mediaUrl: mediaUrl,
            thumbnailUrl: thumbnailUrl,
            fileName: fileName,
            fileSize: fileSize,
            mimeType: mimeType,
            duration: duration,
            isEdited: isEdited,
            reactions: reactions,
            medias: medias,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$MessageTableTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({conversationId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (conversationId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.conversationId,
                    referencedTable:
                        $$MessageTableTableReferences._conversationIdTable(db),
                    referencedColumn: $$MessageTableTableReferences
                        ._conversationIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$MessageTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MessageTableTable,
    MessageTableData,
    $$MessageTableTableFilterComposer,
    $$MessageTableTableOrderingComposer,
    $$MessageTableTableAnnotationComposer,
    $$MessageTableTableCreateCompanionBuilder,
    $$MessageTableTableUpdateCompanionBuilder,
    (MessageTableData, $$MessageTableTableReferences),
    MessageTableData,
    PrefetchHooks Function({bool conversationId})>;
typedef $$AppSettingsTableTableCreateCompanionBuilder
    = AppSettingsTableCompanion Function({
  required String id,
  Value<String> themeMode,
  Value<String> languageCode,
  Value<String> activeAiProvider,
  Value<String> activeAiModel,
  Value<String> geminiApiKey,
  Value<String> localLlmBaseUrl,
  Value<String> systemPrompt,
  Value<String> accessToken,
  Value<String> refreshToken,
  Value<String> serverHost,
  Value<String> userId,
  Value<String> username,
  Value<String> email,
  Value<int> rowid,
});
typedef $$AppSettingsTableTableUpdateCompanionBuilder
    = AppSettingsTableCompanion Function({
  Value<String> id,
  Value<String> themeMode,
  Value<String> languageCode,
  Value<String> activeAiProvider,
  Value<String> activeAiModel,
  Value<String> geminiApiKey,
  Value<String> localLlmBaseUrl,
  Value<String> systemPrompt,
  Value<String> accessToken,
  Value<String> refreshToken,
  Value<String> serverHost,
  Value<String> userId,
  Value<String> username,
  Value<String> email,
  Value<int> rowid,
});

class $$AppSettingsTableTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTableTable> {
  $$AppSettingsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get themeMode => $composableBuilder(
      column: $table.themeMode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get languageCode => $composableBuilder(
      column: $table.languageCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get activeAiProvider => $composableBuilder(
      column: $table.activeAiProvider,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get activeAiModel => $composableBuilder(
      column: $table.activeAiModel, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get geminiApiKey => $composableBuilder(
      column: $table.geminiApiKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get localLlmBaseUrl => $composableBuilder(
      column: $table.localLlmBaseUrl,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get systemPrompt => $composableBuilder(
      column: $table.systemPrompt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get accessToken => $composableBuilder(
      column: $table.accessToken, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get refreshToken => $composableBuilder(
      column: $table.refreshToken, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serverHost => $composableBuilder(
      column: $table.serverHost, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get username => $composableBuilder(
      column: $table.username, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));
}

class $$AppSettingsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTableTable> {
  $$AppSettingsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get themeMode => $composableBuilder(
      column: $table.themeMode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get languageCode => $composableBuilder(
      column: $table.languageCode,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get activeAiProvider => $composableBuilder(
      column: $table.activeAiProvider,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get activeAiModel => $composableBuilder(
      column: $table.activeAiModel,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get geminiApiKey => $composableBuilder(
      column: $table.geminiApiKey,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get localLlmBaseUrl => $composableBuilder(
      column: $table.localLlmBaseUrl,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get systemPrompt => $composableBuilder(
      column: $table.systemPrompt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get accessToken => $composableBuilder(
      column: $table.accessToken, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get refreshToken => $composableBuilder(
      column: $table.refreshToken,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serverHost => $composableBuilder(
      column: $table.serverHost, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get username => $composableBuilder(
      column: $table.username, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));
}

class $$AppSettingsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTableTable> {
  $$AppSettingsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get themeMode =>
      $composableBuilder(column: $table.themeMode, builder: (column) => column);

  GeneratedColumn<String> get languageCode => $composableBuilder(
      column: $table.languageCode, builder: (column) => column);

  GeneratedColumn<String> get activeAiProvider => $composableBuilder(
      column: $table.activeAiProvider, builder: (column) => column);

  GeneratedColumn<String> get activeAiModel => $composableBuilder(
      column: $table.activeAiModel, builder: (column) => column);

  GeneratedColumn<String> get geminiApiKey => $composableBuilder(
      column: $table.geminiApiKey, builder: (column) => column);

  GeneratedColumn<String> get localLlmBaseUrl => $composableBuilder(
      column: $table.localLlmBaseUrl, builder: (column) => column);

  GeneratedColumn<String> get systemPrompt => $composableBuilder(
      column: $table.systemPrompt, builder: (column) => column);

  GeneratedColumn<String> get accessToken => $composableBuilder(
      column: $table.accessToken, builder: (column) => column);

  GeneratedColumn<String> get refreshToken => $composableBuilder(
      column: $table.refreshToken, builder: (column) => column);

  GeneratedColumn<String> get serverHost => $composableBuilder(
      column: $table.serverHost, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);
}

class $$AppSettingsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AppSettingsTableTable,
    AppSettingsTableData,
    $$AppSettingsTableTableFilterComposer,
    $$AppSettingsTableTableOrderingComposer,
    $$AppSettingsTableTableAnnotationComposer,
    $$AppSettingsTableTableCreateCompanionBuilder,
    $$AppSettingsTableTableUpdateCompanionBuilder,
    (
      AppSettingsTableData,
      BaseReferences<_$AppDatabase, $AppSettingsTableTable,
          AppSettingsTableData>
    ),
    AppSettingsTableData,
    PrefetchHooks Function()> {
  $$AppSettingsTableTableTableManager(
      _$AppDatabase db, $AppSettingsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> themeMode = const Value.absent(),
            Value<String> languageCode = const Value.absent(),
            Value<String> activeAiProvider = const Value.absent(),
            Value<String> activeAiModel = const Value.absent(),
            Value<String> geminiApiKey = const Value.absent(),
            Value<String> localLlmBaseUrl = const Value.absent(),
            Value<String> systemPrompt = const Value.absent(),
            Value<String> accessToken = const Value.absent(),
            Value<String> refreshToken = const Value.absent(),
            Value<String> serverHost = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> username = const Value.absent(),
            Value<String> email = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AppSettingsTableCompanion(
            id: id,
            themeMode: themeMode,
            languageCode: languageCode,
            activeAiProvider: activeAiProvider,
            activeAiModel: activeAiModel,
            geminiApiKey: geminiApiKey,
            localLlmBaseUrl: localLlmBaseUrl,
            systemPrompt: systemPrompt,
            accessToken: accessToken,
            refreshToken: refreshToken,
            serverHost: serverHost,
            userId: userId,
            username: username,
            email: email,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String> themeMode = const Value.absent(),
            Value<String> languageCode = const Value.absent(),
            Value<String> activeAiProvider = const Value.absent(),
            Value<String> activeAiModel = const Value.absent(),
            Value<String> geminiApiKey = const Value.absent(),
            Value<String> localLlmBaseUrl = const Value.absent(),
            Value<String> systemPrompt = const Value.absent(),
            Value<String> accessToken = const Value.absent(),
            Value<String> refreshToken = const Value.absent(),
            Value<String> serverHost = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> username = const Value.absent(),
            Value<String> email = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AppSettingsTableCompanion.insert(
            id: id,
            themeMode: themeMode,
            languageCode: languageCode,
            activeAiProvider: activeAiProvider,
            activeAiModel: activeAiModel,
            geminiApiKey: geminiApiKey,
            localLlmBaseUrl: localLlmBaseUrl,
            systemPrompt: systemPrompt,
            accessToken: accessToken,
            refreshToken: refreshToken,
            serverHost: serverHost,
            userId: userId,
            username: username,
            email: email,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AppSettingsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AppSettingsTableTable,
    AppSettingsTableData,
    $$AppSettingsTableTableFilterComposer,
    $$AppSettingsTableTableOrderingComposer,
    $$AppSettingsTableTableAnnotationComposer,
    $$AppSettingsTableTableCreateCompanionBuilder,
    $$AppSettingsTableTableUpdateCompanionBuilder,
    (
      AppSettingsTableData,
      BaseReferences<_$AppDatabase, $AppSettingsTableTable,
          AppSettingsTableData>
    ),
    AppSettingsTableData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ConversationTableTableTableManager get conversationTable =>
      $$ConversationTableTableTableManager(_db, _db.conversationTable);
  $$MessageTableTableTableManager get messageTable =>
      $$MessageTableTableTableManager(_db, _db.messageTable);
  $$AppSettingsTableTableTableManager get appSettingsTable =>
      $$AppSettingsTableTableTableManager(_db, _db.appSettingsTable);
}
