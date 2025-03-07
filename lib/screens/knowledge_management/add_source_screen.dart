import 'package:flutter/material.dart';
import 'package:aichatbot/models/knowledge_base_model.dart';
import 'package:aichatbot/widgets/knowledge/source_forms/common_form_fields.dart';
import 'package:aichatbot/widgets/knowledge/source_forms/file_source_form.dart';
import 'package:aichatbot/widgets/knowledge/source_forms/url_source_form.dart';
import 'package:aichatbot/widgets/knowledge/source_forms/google_drive_form.dart';
import 'package:aichatbot/widgets/knowledge/source_forms/slack_source_form.dart';
import 'package:aichatbot/widgets/knowledge/source_forms/confluence_source_form.dart';

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
  bool _isEditing = false;

  // Form controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _urlController = TextEditingController();
  final _contentController = TextEditingController();

  // Selected source type
  KnowledgeSourceType _selectedType = KnowledgeSourceType.text;

  // URL crawling options
  bool _shouldCrawlLinks = true;
  int _maxPagesToCrawl = 10;
  int _crawlDepth = 1;

  // Mock file selection
  String? _selectedFileName;
  String? _selectedDriveFileName;

  // Slack options
  bool _isSlackConnected = false;
  String? _slackWorkspaceName;
  List<String> _selectedSlackChannels = [];

  // Confluence options
  bool _isConfluenceConnected = false;
  String? _confluenceSpaceName;
  String? _confluenceDomainUrl;
  List<String> _selectedConfluencePages = [];

  @override
  void initState() {
    super.initState();
    _isEditing = widget.editSource != null;

    // Initialize tab controller for different source types - now with 5 tabs instead of 3
    _tabController = TabController(
      length: 5,
      vsync: this,
      initialIndex: _getInitialTabIndex(),
    );

    _tabController.addListener(_handleTabChange);

    if (_isEditing) {
      _loadSourceData();
    }
  }

  int _getInitialTabIndex() {
    if (!_isEditing) return 0; // Default to file tab

    // Set initial tab based on source type if editing
    switch (widget.editSource!.type) {
      case KnowledgeSourceType.pdf:
      case KnowledgeSourceType.docx:
      case KnowledgeSourceType.csv:
      case KnowledgeSourceType.json:
      case KnowledgeSourceType.text:
        return 0; // File tab
      case KnowledgeSourceType.url:
        return 1; // URL tab
      case KnowledgeSourceType.googleDrive:
        return 2; // Google Drive tab
      case KnowledgeSourceType.slack:
        return 3; // Slack tab
      case KnowledgeSourceType.confluence:
        return 4; // Confluence tab
      default:
        return 0;
    }
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      setState(() {
        // When changing tabs, set the appropriate source type for each tab
        switch (_tabController.index) {
          case 0: // File tab
            // Always reset to PDF when switching to file tab to avoid dropdown errors
            _selectedType = KnowledgeSourceType.pdf;
            break;
          case 1: // URL tab
            _selectedType = KnowledgeSourceType.url;
            break;
          case 2: // Google Drive tab
            _selectedType = KnowledgeSourceType.googleDrive;
            break;
          case 3: // Slack tab
            _selectedType = KnowledgeSourceType.slack;
            break;
          case 4: // Confluence tab
            _selectedType = KnowledgeSourceType.confluence;
            break;
        }
      });
    }
  }

  void _loadSourceData() {
    final source = widget.editSource!;
    _titleController.text = source.title;
    _descriptionController.text = source.description;
    _selectedType = source.type;

    switch (source.type) {
      case KnowledgeSourceType.text:
        _contentController.text = source.content;
        break;
      case KnowledgeSourceType.url:
        _urlController.text = source.content;
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
      case KnowledgeSourceType.pdf:
      case KnowledgeSourceType.docx:
      case KnowledgeSourceType.csv:
      case KnowledgeSourceType.json:
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
            _slackWorkspaceName =
                "Your Workspace"; // This would come from metadata
            _selectedSlackChannels = [
              "#general"
            ]; // This would come from metadata
          } catch (e) {
            // Handle parsing error
          }
        }
        break;
      case KnowledgeSourceType.confluence:
        if (source.metadata != null) {
          try {
            _isConfluenceConnected = true;
            _confluenceSpaceName =
                "Documentation"; // This would come from metadata
            _confluenceDomainUrl =
                "your-company.atlassian.net"; // This would come from metadata
            _selectedConfluencePages = [
              "Home"
            ]; // This would come from metadata
          } catch (e) {
            // Handle parsing error
          }
        }
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _urlController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveSource() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();
      String content = '';
      Map<String, dynamic>? metadata;
      String? filePath;

      // Handle different source types
      switch (_selectedType) {
        case KnowledgeSourceType.text:
          content = _contentController.text.trim();
          break;
        case KnowledgeSourceType.url:
          content = _urlController.text.trim();
          metadata = WebsiteMetadata(
            url: content,
            shouldCrawlLinks: _shouldCrawlLinks,
            maxPagesToCrawl: _maxPagesToCrawl,
            crawlDepth: _crawlDepth,
          ).toJson();
          break;
        case KnowledgeSourceType.pdf:
        case KnowledgeSourceType.docx:
        case KnowledgeSourceType.csv:
        case KnowledgeSourceType.json:
          content = "File content would be processed here";
          filePath = _selectedFileName;
          break;
        case KnowledgeSourceType.googleDrive:
          content = "Google Drive content would be linked here";
          metadata = {
            'filename': _selectedDriveFileName,
          };
          break;
        case KnowledgeSourceType.slack:
          content = "Slack integration content";
          metadata = {
            'workspace': _slackWorkspaceName,
            'channels': _selectedSlackChannels,
            'isConnected': _isSlackConnected,
          };
          break;
        case KnowledgeSourceType.confluence:
          content = "Confluence integration content";
          metadata = {
            'domain': _confluenceDomainUrl,
            'space': _confluenceSpaceName,
            'pages': _selectedConfluencePages,
            'isConnected': _isConfluenceConnected,
          };
          break;
        default:
          content = "Unsupported source type";
      }

      final source = KnowledgeSource(
        id: _isEditing
            ? widget.editSource!.id
            : '${now.millisecondsSinceEpoch}_${_selectedType.toString()}',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        type: _selectedType,
        content: content,
        addedAt: _isEditing ? widget.editSource!.addedAt : now,
        lastUpdated: now,
        metadata: metadata,
        filePath: filePath,
      );

      // In a real app, you would save to database or API
      await Future.delayed(
          const Duration(milliseconds: 800)); // Simulate network delay

      // Update knowledge base with new source
      final updatedKnowledgeBase = _isEditing
          ? widget.knowledgeBase.updateSource(source)
          : widget.knowledgeBase.addSource(source);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(_isEditing
                  ? 'Đã cập nhật nguồn dữ liệu'
                  : 'Đã thêm nguồn dữ liệu mới')),
        );
        Navigator.pop(context, updatedKnowledgeBase);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _mockSelectFile() {
    setState(() {
      _selectedFileName = "sample_document.pdf";
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã chọn tệp')),
    );
  }

  void _mockConnectGoogleDrive() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kết nối Google Drive'),
        content: const Text('Đang mô phỏng đăng nhập vào Google Drive...'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _selectedDriveFileName = "my_document.docx";
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã kết nối Google Drive')),
              );
            },
            child: const Text('Mô phỏng kết nối thành công'),
          ),
        ],
      ),
    );
  }

  void _mockConnectSlack() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kết nối Slack'),
        content: const Text('Đang mô phỏng đăng nhập vào Slack...'),
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
                const SnackBar(content: Text('Đã kết nối Slack')),
              );
            },
            child: const Text('Mô phỏng kết nối thành công'),
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã ngắt kết nối Slack')),
    );
  }

  void _mockConnectConfluence() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kết nối Confluence'),
        content: const Text('Đang mô phỏng đăng nhập vào Confluence...'),
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
                const SnackBar(content: Text('Đã kết nối Confluence')),
              );
            },
            child: const Text('Mô phỏng kết nối thành công'),
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
      const SnackBar(content: Text('Đã ngắt kết nối Confluence')),
    );
  }

  void _clearSelectedFile() {
    setState(() {
      _selectedFileName = null;
    });
  }

  void _clearSelectedDriveFile() {
    setState(() {
      _selectedDriveFileName = null;
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
    return Scaffold(
      appBar: _buildAppBar(),
      body: _isLoading ? _buildLoadingIndicator() : _buildForm(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(_isEditing ? 'Sửa nguồn dữ liệu' : 'Thêm nguồn dữ liệu'),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildTabBar(),
          _buildFormContent(),
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Material(
      color: Theme.of(context).primaryColor,
      child: TabBar(
        controller: _tabController,
        isScrollable: true, // Make tabs scrollable to fit all 5
        tabs: const [
          Tab(text: "Tệp", icon: Icon(Icons.insert_drive_file)),
          Tab(text: "Website", icon: Icon(Icons.language)),
          Tab(text: "Google Drive", icon: Icon(Icons.cloud)),
          Tab(text: "Slack", icon: Icon(Icons.forum)),
          Tab(text: "Confluence", icon: Icon(Icons.book_online)),
        ],
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        indicatorColor: Colors.white,
      ),
    );
  }

  Widget _buildFormContent() {
    final primaryColor = Theme.of(context).primaryColor;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // Common fields
            CommonFormFields(
              titleController: _titleController,
              descriptionController: _descriptionController,
              primaryColor: primaryColor,
            ),
            const SizedBox(height: 24),

            // Source-specific fields based on selected tab
            IndexedStack(
              index: _tabController.index,
              children: [
                // File tab - use a fixed valid type (PDF) to ensure dropdown has a valid selection
                FileSourceForm(
                  selectedType: _selectedType == KnowledgeSourceType.pdf ||
                          _selectedType == KnowledgeSourceType.docx ||
                          _selectedType == KnowledgeSourceType.text ||
                          _selectedType == KnowledgeSourceType.csv ||
                          _selectedType == KnowledgeSourceType.json
                      ? _selectedType
                      : KnowledgeSourceType
                          .pdf, // Default to PDF if current type isn't in dropdown
                  contentController: _contentController,
                  selectedFileName: _selectedFileName,
                  onTypeChanged: _onFileTypeChanged,
                  onSelectFile: _mockSelectFile,
                  onClearFile: _clearSelectedFile,
                  primaryColor: primaryColor,
                ),

                // URL tab
                UrlSourceForm(
                  urlController: _urlController,
                  shouldCrawlLinks: _shouldCrawlLinks,
                  maxPagesToCrawl: _maxPagesToCrawl,
                  crawlDepth: _crawlDepth,
                  onCrawlLinksChanged: _onCrawlLinksChanged,
                  onMaxPagesChanged: _onMaxPagesChanged,
                  onCrawlDepthChanged: _onCrawlDepthChanged,
                  primaryColor: primaryColor,
                ),

                // Google Drive tab
                GoogleDriveForm(
                  selectedDriveFileName: _selectedDriveFileName,
                  onConnectDrive: _mockConnectGoogleDrive,
                  onClearSelection: _clearSelectedDriveFile,
                  onSelectDifferent: _mockConnectGoogleDrive,
                  primaryColor: primaryColor,
                ),

                // Slack tab
                SlackSourceForm(
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
                  primaryColor: primaryColor,
                ),

                // Confluence tab
                ConfluenceSourceForm(
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
                  primaryColor: primaryColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveSource,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              )
            : Text(_isEditing ? 'Cập nhật' : 'Thêm nguồn dữ liệu'),
      ),
    );
  }
}
