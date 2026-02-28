import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  PackageInfo? _packageInfo;
  
  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }
  
  Future<void> _loadPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _packageInfo = info;
      });
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('无法打开链接: $url')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('打开链接失败: $e')),
        );
      }
    }
  }

  void _checkUpdate() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('当前已是最新版本'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showLicenses() {
    showLicensePage(
      context: context,
      applicationName: 'Syncro',
      applicationVersion: _packageInfo?.version ?? '1.0.0',
      applicationIcon: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Image.asset(
          'assets/icons/syncro_C_512x512.png',
          width: 80,
          height: 80,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('关于'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 32),
            
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                'assets/icons/syncro_C_512x512.png',
                width: 120,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
            
            const SizedBox(height: 24),
            
            Text(
              'Syncro',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              _packageInfo != null 
                  ? 'V ${_packageInfo!.version} (${_packageInfo!.buildNumber})'
                  : 'V 1.0.0',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: colorScheme.outline,
              ),
            ),
            
            const SizedBox(height: 32),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Syncro 是一款跨平台视频同步播放应用，支持多人在线同步观看视频。'
                '无论您和朋友相隔多远，都能一起享受同步的观影体验。',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.6,
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            Card(
              elevation: 0,
              color: colorScheme.surfaceContainerLow,
              child: Column(
                children: [
                  _buildListTile(
                    icon: Icons.update,
                    title: '检查更新',
                    subtitle: '检查是否有新版本',
                    onTap: _checkUpdate,
                  ),
                  Divider(height: 1, indent: 56, endIndent: 16, color: colorScheme.outlineVariant),
                  _buildListTile(
                    icon: Icons.code,
                    title: 'GitHub 开源地址',
                    subtitle: 'github.com/OYlili/syncro',
                    onTap: () => _launchUrl('https://github.com/OYlili/syncro'),
                  ),
                  Divider(height: 1, indent: 56, endIndent: 16, color: colorScheme.outlineVariant),
                  _buildListTile(
                    icon: Icons.description_outlined,
                    title: '开源协议声明',
                    subtitle: '查看使用的开源库',
                    onTap: _showLicenses,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            Card(
              elevation: 0,
              color: colorScheme.surfaceContainerLow,
              child: Column(
                children: [
                  _buildInfoTile('应用名称', _packageInfo?.appName ?? 'Syncro'),
                  Divider(height: 1, indent: 16, endIndent: 16, color: colorScheme.outlineVariant),
                  _buildInfoTile('包名', _packageInfo?.packageName ?? 'com.syncro.app'),
                  Divider(height: 1, indent: 16, endIndent: 16, color: colorScheme.outlineVariant),
                  _buildInfoTile('版本号', _packageInfo?.version ?? '1.0.0'),
                  Divider(height: 1, indent: 16, endIndent: 16, color: colorScheme.outlineVariant),
                  _buildInfoTile('构建号', _packageInfo?.buildNumber ?? '1'),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            Text(
              '© 2024 Syncro Team',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.outline,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'Made with ❤️ using Flutter',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.outline,
              ),
            ),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return ListTile(
      title: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
      trailing: Text(
        value,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }
}
