/*
 *
 *  * Copyright (c) 2024 Mindful (https://github.com/akaMrNagar/Mindful)
 *  * Author : Pawan Nagar (https://github.com/akaMrNagar)
 *  *
 *  * This source code is licensed under the GPL-2.0 license license found in the
 *  * LICENSE file in the root directory of this source tree.
 *
 */

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindful/core/enums/item_position.dart';
import 'package:mindful/core/extensions/ext_build_context.dart';
import 'package:mindful/core/services/method_channel_service.dart';
import 'package:mindful/models/app_info.dart';
import 'package:mindful/providers/restrictions/apps_restrictions_provider.dart';
import 'package:mindful/ui/common/default_list_tile.dart';

// ponytail: release package id only; debug builds (.debug suffix) need the id edited manually.
const _fullCommand =
    'adb shell pm grant com.mindful.android android.permission.WRITE_SECURE_SETTINGS';
const _shellCommand =
    'pm grant com.mindful.android android.permission.WRITE_SECURE_SETTINGS';
const _rootCommand =
    'su -c pm grant com.mindful.android android.permission.WRITE_SECURE_SETTINGS';

/// Tile to toggle grayscale while the given app is open.
class AppGrayscaleTile extends ConsumerWidget {
  const AppGrayscaleTile({required this.appInfo, super.key});

  final AppInfo appInfo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(appsRestrictionsProvider
            .select((v) => v[appInfo.packageName]?.grayscaleEnabled)) ??
        false;

    return DefaultListTile(
      position: ItemPosition.mid,
      switchValue: enabled,
      enabled: !appInfo.isImpSysApp,
      titleText: context.locale.grayscale_tile_title,
      subtitleText: context.locale.grayscale_tile_subtitle,
      leadingIcon:
          enabled ? FluentIcons.color_20_filled : FluentIcons.color_20_regular,
      onPressed: () => _onPressed(context, ref, enabled),
    );
  }

  Future<void> _onPressed(
    BuildContext context,
    WidgetRef ref,
    bool enabled,
  ) async {
    if (!enabled) {
      final granted = await MethodChannelService.instance
          .hasWriteSecureSettingsPermission();
      if (!context.mounted) return;
      if (!granted) {
        await showDialog(
          context: context,
          builder: (_) => const _PermissionDialog(),
        );
        return;
      }
    }

    ref
        .read(appsRestrictionsProvider.notifier)
        .switchGrayscale(appInfo.packageName, !enabled);
  }
}

class _PermissionDialog extends StatelessWidget {
  const _PermissionDialog();

  @override
  Widget build(BuildContext context) {
    final l = context.locale;
    final titleStyle = Theme.of(context).textTheme.titleSmall;

    Widget section(String title, String steps, String command) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(title, style: titleStyle),
            const SizedBox(height: 4),
            Text(steps),
            _CommandRow(command: command),
          ],
        );

    return AlertDialog(
      title: Text(l.grayscale_permission_dialog_title),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            section(l.grayscale_permission_usb_title,
                l.grayscale_permission_usb_steps, _fullCommand),
            section(l.grayscale_permission_wireless_title,
                l.grayscale_permission_wireless_steps, _fullCommand),
            section(l.grayscale_permission_ladb_title,
                l.grayscale_permission_ladb_steps, _shellCommand),
            section(l.grayscale_permission_shizuku_title,
                l.grayscale_permission_shizuku_steps, _shellCommand),
            section(l.grayscale_permission_root_title,
                l.grayscale_permission_root_steps, _rootCommand),
            const SizedBox(height: 16),
            Text(l.grayscale_permission_persistence),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(MaterialLocalizations.of(context).okButtonLabel),
        ),
      ],
    );
  }
}

class _CommandRow extends StatelessWidget {
  const _CommandRow({required this.command});

  final String command;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SelectableText(
            command,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontFamily: 'monospace'),
          ),
        ),
        IconButton(
          tooltip: context.locale.grayscale_permission_copy_command,
          icon: const Icon(FluentIcons.copy_20_regular),
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: command));
            if (!context.mounted) return;
            context.showSnackAlert(
              context.locale.grayscale_command_copied_snack_alert,
            );
          },
        ),
      ],
    );
  }
}
