import 'dart:io';
import 'package:aichatbot/data/models/knowledge/file_upload_response.dart';
import 'package:aichatbot/models/knowledge_base_model.dart';
import 'package:aichatbot/presentation/bloc/auth/auth_bloc.dart';
import 'package:aichatbot/presentation/bloc/file_upload/file_upload_bloc.dart';
import 'package:aichatbot/presentation/bloc/file_upload/file_upload_event.dart';
import 'package:aichatbot/presentation/bloc/file_upload/file_upload_state.dart';
import 'package:aichatbot/utils/google_auth_client.dart';
import 'package:aichatbot/utils/logger.dart';
import 'package:aichatbot/widgets/knowledge/source_forms/confluence_source_form.dart';
import 'package:aichatbot/widgets/knowledge/source_forms/slack_source_form.dart';
import 'package:aichatbot/widgets/knowledge/source_forms/url_source_form.dart';
import 'package:aichatbot/widgets/knowledge/source_preview_card.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aichatbot/core/di/injection_container.dart' as di;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;

class AddSourceScreen extends StatefulWidget {
  final KnowledgeBase knowledgeBase;
  final KnowledgeSource? editSource;

  const AddSourceScreen({
    super.key,
    required this.knowledgeBase,
    this.editSource,
  });

  @override
  State<AddSourceScreen> createState() => _AddSourceScreenState();
}

class _AddSourceScreenState extends State<AddSourceScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TabController _tabController;
  bool _isLoading = false;
  final bool _isEditing = false;
  KnowledgeSourceType _selectedType = KnowledgeSourceType.local_file;
  bool _shouldCrawlLinks = true;
  int _maxPagesToCrawl = 10;
  int _crawlDepth = 1;
  String? _selectedFileName;
  File? _selectedFile;
  String? _selectedDriveFileName;
  String? _selectedDriveFileId;
  bool _isSlackConnected = false;
  String? _slackWorkspaceName;
  List<String> _selectedSlackChannels = [];
  bool _isConfluenceConnected = false;
  String? _confluenceSpaceName;
  String? _confluenceDomainUrl;
  List<String> _selectedConfluencePages = [];
  Map<String, dynamic>? _fileMetadata;
  late final FileUploadBloc _fileUploadBloc;
  late GoogleSignIn _googleSignIn;

  @override
  void initState() {
    super.initState();
    _googleSignIn = GoogleSignIn(
      scopes: [drive.DriveApi.driveReadonlyScope],
    );
    _fileUploadBloc = di.sl<FileUploadBloc>();
    _tabController = TabController(
      length: 5,
      vsync: this,
      initialIndex: _getInitialTabIndex(),
    );
    _tabController.addListener(_handleTabChange);
    if (widget.editSource != null) {
      _loadSourceData();
    }
  }

  int _getInitialTabIndex() {
    if (!_isEditing) return 0;

    switch (widget.editSource!.type) {
      case KnowledgeSourceType.local_file:
        return 0;
      case KnowledgeSourceType.website:
        return 1;
      case KnowledgeSourceType.googleDrive:
        return 2;
      case KnowledgeSourceType.slack:
        return 3;
      case KnowledgeSourceType.confluence:
        return 4;
    }
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      setState(() {
        switch (_tabController.index) {
          case 0:
            _selectedType = KnowledgeSourceType.local_file;
            break;
          case 1:
            _selectedType = KnowledgeSourceType.website;
            break;
          case 2:
            _selectedType = KnowledgeSourceType.googleDrive;
            break;
          case 3:
            _selectedType = KnowledgeSourceType.slack;
            break;
          case 4:
            _selectedType = KnowledgeSourceType.confluence;
            break;
        }
      });
    }
  }

  void _loadSourceData() {
    final source = widget.editSource!;
    _selectedType = source.type;

    switch (source.type) {
      case KnowledgeSourceType.website:
        if (source.metadata != null) {
          try {
            final metadata = WebsiteMetadata.fromJson(source.metadata!);
            _shouldCrawlLinks = metadata.shouldCrawlLinks;
            _maxPagesToCrawl = metadata.maxPagesToCrawl;
            _crawlDepth = metadata.crawlDepth;
          } catch (e) {
            // Handle parsing error
          }
        }
        break;
      case KnowledgeSourceType.local_file:
        _selectedFileName = source.filePath ?? "Selected file";
        break;
      case KnowledgeSourceType.googleDrive:
        if (source.metadata != null) {
          try {
            _selectedDriveFileName = "Google Drive file";
          } catch (e) {
            // Handle parsing error
          }
        }
        break;
      case KnowledgeSourceType.slack:
        if (source.metadata != null) {
          try {
            _isSlackConnected = true;
            _slackWorkspaceName = "Your Workspace";
            _selectedSlackChannels = ["#general"];
          } catch (e) {
            // Handle parsing error
          }
        }
        break;
      case KnowledgeSourceType.confluence:
        if (source.metadata != null) {
          try {
            _isConfluenceConnected = true;
            _confluenceSpaceName = "Documentation";
            _confluenceDomainUrl = "your-company.atlassian.net";
            _selectedConfluencePages = ["Home"];
          } catch (e) {
            // Handle parsing error
          }
        }
        break;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _saveSource() async {
    AppLogger.d("_saveSource: Method started");

    switch (_selectedType) {
      case KnowledgeSourceType.local_file:
        if (_selectedFile == null) {
          AppLogger.d("_saveSource: No file selected, returning early");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a file to upload')),
          );
          return;
        }
        _uploadLocalFile();
        break;
      case KnowledgeSourceType.googleDrive:
        _saveGoogleDriveSource();
        break;
      case KnowledgeSourceType.website:
        _saveWebsiteSource();
        break;
      case KnowledgeSourceType.slack:
        _saveSlackSource();
        break;
      case KnowledgeSourceType.confluence:
        _saveConfluenceSource();
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Select a valid source type')),
        );
    }
  }

  Future<void> _uploadLocalFile() async {
    setState(() => _isLoading = true);

    try {
      AppLogger.d("_uploadLocalFile: Starting to upload local file");

      if (_selectedFile != null) {
        AppLogger.d(
            "_uploadLocalFile: File selected, preparing for upload: ${_selectedFile!.path}");

        final authState = context.read<AuthBloc>().state;
        final accessToken = authState.user?.accessToken;

        AppLogger.d(
            "_uploadLocalFile: Auth token available: ${accessToken != null}");

        if (accessToken == null) {
          throw Exception('Authentication required');
        }

        AppLogger.d("_uploadLocalFile: Dispatching UploadLocalFileEvent");
        _fileUploadBloc.add(
          UploadLocalFileEvent(
            knowledgeId: widget.knowledgeBase.id,
            file: _selectedFile!,
            accessToken: accessToken,
          ),
        );

        AppLogger.d(
            "_uploadLocalFile: Event dispatched, waiting for BlocListener");
      }
    } catch (e) {
      AppLogger.e("_uploadLocalFile: Error occurred: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

// Add these placeholder methods for other source types
  Future<void> _saveWebsiteSource() async {
    // Implement website source upload
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Website source upload not implemented yet')),
    );
  }

  Future<void> _saveSlackSource() async {
    // Implement Slack source upload
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Slack source upload not implemented yet')),
    );
  }

  Future<void> _saveConfluenceSource() async {
    // Implement Confluence source upload
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Confluence source upload not implemented yet')),
    );
  }

  Future<void> _mockSelectFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );

      if (result != null && result.files.single.path != null) {
        final fileName = result.files.single.name;
        final filePath = result.files.single.path!;
        final fileExtension = fileName.split('.').last.toLowerCase();

        _selectedType = KnowledgeSourceType.local_file;

        Map<String, dynamic> metadata = {
          'fileFormat': fileExtension,
          'originalFileName': fileName,
          'fileSize': result.files.single.size,
        };

        setState(() {
          _selectedFileName = fileName;
          _selectedFile = File(filePath);
          _fileMetadata = metadata;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Selected file: $fileName')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting file: $e')),
      );
    }
  }

  Future<void> _pickDriveFile() async {
    setState(() => _isLoading = true);
    try {
      // 1. Sign in (hoặc lấy lại token nếu đã connect)
      final account = await _googleSignIn.signIn();
      if (account == null) throw Exception('Chưa sign in Google');
      final authHeaders = await account.authHeaders;
      final client = GoogleAuthClient(authHeaders);

      // 2. Tạo Drive API client và list file
      final driveApi = drive.DriveApi(client);
      final fileList = await driveApi.files.list(
        pageSize: 20,
        $fields: 'files(id,name,mimeType)',
      );

      // 3. Hiển thị dialog để chọn file
      final picked = await showDialog<drive.File>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Select a Google Drive file'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: fileList.files!
                  .map((f) => ListTile(
                        leading: const Icon(Icons.insert_drive_file),
                        title: Text(f.name ?? ''),
                        subtitle: Text(f.mimeType ?? ''),
                        onTap: () => Navigator.pop(context, f),
                      ))
                  .toList(),
            ),
          ),
        ),
      );

      if (picked != null) {
        setState(() {
          _selectedDriveFileId = picked.id;
          _selectedDriveFileName = picked.name;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Selected: ${picked.name}')),
        );
      }
    } catch (e) {
      AppLogger.e("Google Picker error: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveGoogleDriveSource() async {
    if (_selectedDriveFileId == null || _selectedDriveFileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bạn phải chọn file trước')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final auth = context.read<AuthBloc>().state;
      final token = auth.user?.accessToken;
      final userId = auth.user?.id;
      if (token == null || userId == null) throw Exception('Chưa login');

      final now = DateTime.now().toIso8601String();

      _fileUploadBloc.add(
        UploadGoogleDriveEvent(
          knowledgeId: widget.knowledgeBase.id,
          id: _selectedDriveFileId!,
          name: _selectedDriveFileName!,
          status: true,
          userId: userId,
          createdAt: now,
          accessToken: token,
        ),
      );
    } catch (e) {
      AppLogger.e("Lỗi upload Drive: $e");
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _mockConnectSlack() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Connect Slack'),
        content: const Text('Simulating login to Slack...'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _isSlackConnected = true;
                _slackWorkspaceName = "Your Workspace";
                _selectedSlackChannels = ["#general"];
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Connected to Slack')),
              );
            },
            child: const Text('Simulate successful connection'),
          ),
        ],
      ),
    );
  }

  void _mockDisconnectSlack() {
    setState(() {
      _isSlackConnected = false;
      _slackWorkspaceName = null;
      _selectedSlackChannels = [];
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Disconnected from Slack')));
  }

  void _mockConnectConfluence() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Connect Confluence'),
        content: const Text('Simulating login to Confluence...'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _isConfluenceConnected = true;
                _confluenceSpaceName = "Documentation";
                _confluenceDomainUrl = "your-company.atlassian.net";
                _selectedConfluencePages = ["Home"];
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Connected to Confluence')),
              );
            },
            child: const Text('Simulate successful connection'),
          ),
        ],
      ),
    );
  }

  void _mockDisconnectConfluence() {
    setState(() {
      _isConfluenceConnected = false;
      _confluenceSpaceName = null;
      _confluenceDomainUrl = null;
      _selectedConfluencePages = [];
    });
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Disconnected from Confluence')));
  }

  void _clearSelectedFile() {
    setState(() {
      _selectedFileName = null;
      _selectedFile = null;
    });
  }

  void _clearSelectedDriveFile() {
    setState(() {
      _selectedDriveFileName = null;
      _selectedDriveFileId = null;
    });
  }

  void _onFileTypeChanged(KnowledgeSourceType type) {
    setState(() {
      _selectedType = type;
    });
  }

  void _onCrawlLinksChanged(bool value) {
    setState(() {
      _shouldCrawlLinks = value;
    });
  }

  void _onMaxPagesChanged(double value) {
    setState(() {
      _maxPagesToCrawl = value.toInt();
    });
  }

  void _onCrawlDepthChanged(double value) {
    setState(() {
      _crawlDepth = value.toInt();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _fileUploadBloc,
      child: BlocListener<FileUploadBloc, FileUploadState>(
        listener: (context, state) {
          if (state is FileUploadLoading) {
            setState(() => _isLoading = true);
          } else if (state is FileUploadSuccess) {
            setState(() => _isLoading = false);
            final updatedKnowledgeBase = _isEditing
                ? widget.knowledgeBase
                    .updateSource(_createSourceFromUpload(state.response))
                : widget.knowledgeBase
                    .addSource(_createSourceFromUpload(state.response));

            _showSuccessSnackbar(_isEditing
                ? 'Source updated successfully'
                : 'New source added successfully');

            Navigator.pop(context, updatedKnowledgeBase);
          } else if (state is FileUploadError) {
            setState(() => _isLoading = false);
            _showErrorSnackbar(state.message);
          }
        },
        child: Scaffold(
          appBar: _buildAppBar(),
          body: _isLoading ? _buildLoadingIndicator() : _buildForm(),
        ),
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text('Error: $message')),
          ],
        ),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(_isEditing ? 'Edit Data Source' : 'Add Data Source'),
      elevation: 0,
      centerTitle: true,
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
      bottom: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorColor: Colors.white,
        indicatorWeight: 3,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white.withOpacity(0.7),
        tabs: const [
          Tab(icon: Icon(Icons.insert_drive_file), text: "File"),
          Tab(icon: Icon(Icons.language), text: "Website"),
          Tab(icon: Icon(Icons.cloud), text: "Google Drive"),
          Tab(icon: Icon(Icons.forum), text: "Slack"),
          Tab(icon: Icon(Icons.book_online), text: "Confluence"),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _isEditing ? "Updating source..." : "Adding source...",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFileUploadTab(),
                _buildWebsiteTab(),
                _buildGoogleDriveTab(),
                _buildSlackTab(),
                _buildConfluenceTab(),
              ],
            ),
          ),
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildFileUploadTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and description
          _buildSectionHeader(
            "Upload a File",
            "Add documents like PDFs, Word files, or text files to your knowledge base",
            Icons.cloud_upload,
          ),
          const SizedBox(height: 24),

          // File preview card
          SourcePreviewCard(
            fileName: _selectedFileName,
            onClear: _clearSelectedFile,
            fileIcon: _getFileIcon(),
            iconColor: _getFileIconColor(),
          ),

          const SizedBox(height: 24),

          // Upload button
          Center(
            child: ElevatedButton.icon(
              onPressed: _mockSelectFile,
              icon: const Icon(Icons.upload_file),
              label: Text(
                  _selectedFileName == null ? "Select File" : "Change File"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Supported file formats
          _buildSupportInfo(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 40),
          child: Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Divider(),
      ],
    );
  }

  IconData _getFileIcon() {
    if (_selectedFileName == null) return Icons.insert_drive_file;

    final extension = _selectedFileName!.split('.').last.toLowerCase();

    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      case 'txt':
        return Icons.text_snippet;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getFileIconColor() {
    if (_selectedFileName == null) return Colors.blue;

    final extension = _selectedFileName!.split('.').last.toLowerCase();

    switch (extension) {
      case 'pdf':
        return Colors.red;
      case 'doc':
      case 'docx':
        return Colors.blue;
      case 'xls':
      case 'xlsx':
        return Colors.green;
      case 'ppt':
      case 'pptx':
        return Colors.orange;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Colors.purple;
      default:
        return Colors.blue;
    }
  }

  Widget _buildSupportInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[700]),
              const SizedBox(width: 8),
              Text(
                "Supported File Types",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildFileTypeChip("PDF", Colors.red),
          _buildFileTypeChip("Word Documents", Colors.blue),
          _buildFileTypeChip("Excel Spreadsheets", Colors.green),
          _buildFileTypeChip("PowerPoint", Colors.orange),
          _buildFileTypeChip("Text Files", Colors.grey),
          _buildFileTypeChip("CSV", Colors.purple),
          _buildFileTypeChip("JSON", Colors.amber),
        ],
      ),
    );
  }

  Widget _buildFileTypeChip(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 16, color: color),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildWebsiteTab() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: UrlSourceForm(
        urlController: TextEditingController(),
        shouldCrawlLinks: _shouldCrawlLinks,
        maxPagesToCrawl: _maxPagesToCrawl,
        crawlDepth: _crawlDepth,
        onCrawlLinksChanged: _onCrawlLinksChanged,
        onMaxPagesChanged: _onMaxPagesChanged,
        onCrawlDepthChanged: _onCrawlDepthChanged,
        primaryColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildGoogleDriveTab() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            "Google Drive",
            "Chọn file từ Google Drive của bạn",
            Icons.cloud,
          ),
          const SizedBox(height: 24),

          // nếu đã chọn file
          if (_selectedDriveFileName != null && _selectedDriveFileId != null)
            Row(
              children: [
                Expanded(
                    child: Text(_selectedDriveFileName!,
                        style: const TextStyle(fontSize: 16))),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() {
                    _selectedDriveFileName = null;
                    _selectedDriveFileId = null;
                  }),
                )
              ],
            )
          else
            Center(
              child: ElevatedButton.icon(
                onPressed: _pickDriveFile,
                icon: const Icon(Icons.drive_file_rename_outline),
                label: const Text("Select from Drive"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),

          const Spacer(),

          // Nút Lưu/Upload
          ElevatedButton(
            onPressed:
                _selectedDriveFileId == null ? null : _saveGoogleDriveSource,
            child: const Text("Upload to Knowledge"),
          ),
        ],
      ),
    );
  }

  Widget _buildSlackTab() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SlackSourceForm(
        isConnected: _isSlackConnected,
        workspaceName: _slackWorkspaceName,
        selectedChannels: _selectedSlackChannels,
        onConnect: _mockConnectSlack,
        onDisconnect: _mockDisconnectSlack,
        onChannelsSelected: (channels) {
          setState(() {
            _selectedSlackChannels = channels;
          });
        },
        primaryColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildConfluenceTab() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: ConfluenceSourceForm(
        isConnected: _isConfluenceConnected,
        spaceName: _confluenceSpaceName,
        domainUrl: _confluenceDomainUrl,
        selectedPages: _selectedConfluencePages,
        onConnect: _mockConnectConfluence,
        onDisconnect: _mockDisconnectConfluence,
        onPagesSelected: (pages) {
          setState(() {
            _selectedConfluencePages = pages;
          });
        },
        primaryColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveSource,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(_isEditing ? 'Updating...' : 'Adding...'),
                ],
              )
            : Text(_isEditing ? 'Update Source' : 'Add Data Source'),
      ),
    );
  }

  KnowledgeSource _createSourceFromUpload(FileUploadResponse response) {
    final now = DateTime.now();
    return KnowledgeSource(
      id: response.id,
      title: response.name,
      description: "Uploaded file",
      type: _getSourceTypeFromMimetype(response.metadata.mimetype),
      content: response.name,
      addedAt: now,
      lastUpdated: now,
      metadata: {
        'size': response.size,
        'mimetype': response.metadata.mimetype,
        'openAiFileIds': response.openAiFileIds,
      },
      filePath: response.name,
    );
  }

  KnowledgeSourceType _getSourceTypeFromMimetype(String mimetype) {
    return _selectedType;
  }
}
