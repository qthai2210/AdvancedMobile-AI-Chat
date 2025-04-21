import 'dart:io';
import 'package:aichatbot/data/models/knowledge/file_upload_response.dart';
import 'package:aichatbot/models/knowledge_base_model.dart';
import 'package:aichatbot/presentation/bloc/auth/auth_bloc.dart';
import 'package:aichatbot/presentation/bloc/file_upload/file_upload_bloc.dart';
import 'package:aichatbot/presentation/bloc/file_upload/file_upload_event.dart';
import 'package:aichatbot/presentation/bloc/file_upload/file_upload_state.dart';
import 'package:aichatbot/utils/logger.dart';
import 'package:aichatbot/widgets/knowledge/source_forms/confluence_source_form.dart';
import 'package:aichatbot/widgets/knowledge/source_forms/google_drive_form.dart';
import 'package:aichatbot/widgets/knowledge/source_forms/slack_source_form.dart';
import 'package:aichatbot/widgets/knowledge/source_forms/url_source_form.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Fix import paths by using your actual package name instead of 'aichatbot'
import 'package:aichatbot/widgets/knowledge/source_forms/common_form_fields.dart';
import 'package:aichatbot/core/di/injection_container.dart' as di;

/// A screen for adding or editing knowledge sources to a knowledge base.
///
/// Supports multiple source types including:
/// * File uploads (PDF, DOCX, CSV, JSON, Text)
/// * Website URLs with crawling options
/// * Google Drive integration
/// * Slack integration
/// * Confluence integration
class AddSourceScreen extends StatefulWidget {
  /// The knowledge base to add the source to
  final KnowledgeBase knowledgeBase;

  /// Optional existing source for editing mode
  final KnowledgeSource? editSource;

  const AddSourceScreen({
    super.key,
    required this.knowledgeBase,
    this.editSource,
  });

  @override
  State<AddSourceScreen> createState() => _AddSourceScreenState();
}

/// State management for the [AddSourceScreen].
/// Handles form input, validation, and source creation/editing.
class _AddSourceScreenState extends State<AddSourceScreen>
    with SingleTickerProviderStateMixin {
  /// Form key for validation
  final _formKey = GlobalKey<FormState>();

  /// Controller for source type tabs
  late TabController _tabController;

  /// Loading state for async operations
  bool _isLoading = false;

  /// Whether we're editing an existing source
  final bool _isEditing = false;

  // Selected source type
  KnowledgeSourceType _selectedType = KnowledgeSourceType.local_file;

  // URL crawling options
  bool _shouldCrawlLinks = true;
  int _maxPagesToCrawl = 10;
  int _crawlDepth = 1;

  // Mock file selection
  String? _selectedFileName;
  File? _selectedFile;
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
  Map<String, dynamic>? _fileMetadata;

  // Create a local instance of FileUploadBloc
  late final FileUploadBloc _fileUploadBloc;

  @override
  void initState() {
    super.initState();

    // Initialize FileUploadBloc using dependency injection
    _fileUploadBloc = di.sl<FileUploadBloc>();

    // Initialize tab controller for different source types
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

  /// Gets the initial tab index based on source type when editing
  int _getInitialTabIndex() {
    if (!_isEditing) return 0; // Default to file tab

    // Set initial tab based on source type if editing
    switch (widget.editSource!.type) {
      case KnowledgeSourceType.local_file:
        return 0; // File tab
      case KnowledgeSourceType.website:
        return 1; // URL tab
      case KnowledgeSourceType.googleDrive:
        return 2; // Google Drive tab
      case KnowledgeSourceType.slack:
        return 3; // Slack tab
      case KnowledgeSourceType.confluence:
        return 4;
    }
  }

  /// Handles source type changes when switching tabs
  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      setState(() {
        // When changing tabs, set the appropriate source type for each tab
        switch (_tabController.index) {
          case 0: // File tab
            _selectedType = KnowledgeSourceType.local_file;
            break;
          case 1: // URL tab
            _selectedType = KnowledgeSourceType.website;
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

  /// Loads existing source data when in edit mode
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

  /// Saves the source data and updates the knowledge base
  Future<void> _saveSource() async {
    AppLogger.d("_saveSource: Method started");

    // Simplified validation - only check if a file is selected
    if (_selectedFile == null) {
      AppLogger.d("_saveSource: No file selected, returning early");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a file to upload')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      AppLogger.d("_saveSource: Starting to save source");

      // For file upload sources, use the FileUploadBloc
      if (_selectedFile != null) {
        AppLogger.d(
            "_saveSource: File selected, preparing for upload: ${_selectedFile!.path}");

        // Get auth token from AuthBloc
        final authState = context.read<AuthBloc>().state;
        final accessToken = authState.user?.accessToken;

        AppLogger.d(
            "_saveSource: Auth token available: ${accessToken != null}");

        if (accessToken == null) {
          throw Exception('Authentication required');
        }

        // Use the local instance directly instead of trying to read from context
        AppLogger.d("_saveSource: Dispatching UploadLocalFileEvent");
        _fileUploadBloc.add(
          UploadLocalFileEvent(
            knowledgeId: widget.knowledgeBase.id,
            file: _selectedFile!,
            accessToken: accessToken,
          ),
        );

        AppLogger.d("_saveSource: Event dispatched, waiting for BlocListener");
        // The rest will be handled by the BlocListener
        return;
      }
    } catch (e) {
      AppLogger.e("_saveSource: Error occurred: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Select a file from the device storage
  Future<void> _mockSelectFile() async {
    try {
      // Use file_picker to select any file type
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );

      if (result != null && result.files.single.path != null) {
        final fileName = result.files.single.name;
        final filePath = result.files.single.path!;
        final fileExtension = fileName.split('.').last.toLowerCase();

        // Always use localFile type
        _selectedType = KnowledgeSourceType.local_file;

        // Store the file format in metadata instead
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

  void _mockConnectGoogleDrive() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Connect Google Drive'),
        content: const Text('Simulating login to Google Drive...'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _selectedDriveFileName = "my_document.docx";
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Connected to Google Drive')),
              );
            },
            child: const Text('Simulate successful connection'),
          ),
        ],
      ),
    );
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
    // Use BlocProvider.value to provide the existing bloc instance
    return BlocProvider.value(
      value: _fileUploadBloc,
      child: BlocListener<FileUploadBloc, FileUploadState>(
        listener: (context, state) {
          AppLogger.d("BlocListener: Received state: $state");

          if (state is FileUploadLoading) {
            setState(() => _isLoading = true);
          } else if (state is FileUploadSuccess) {
            // Handle successful upload
            setState(() => _isLoading = false);
            final updatedKnowledgeBase = _isEditing
                ? widget.knowledgeBase
                    .updateSource(_createSourceFromUpload(state.response))
                : widget.knowledgeBase
                    .addSource(_createSourceFromUpload(state.response));

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(_isEditing
                      ? 'Source updated successfully'
                      : 'New source added successfully')),
            );
            Navigator.pop(context, updatedKnowledgeBase);
          } else if (state is FileUploadError) {
            // Handle upload error
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.message}')),
            );
          }
        },
        child: Scaffold(
          appBar: _buildAppBar(),
          body: _isLoading ? _buildLoadingIndicator() : _buildForm(),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(_isEditing ? 'Edit Data Source' : 'Add Data Source'),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(child: CircularProgressIndicator());
  }

  /// Builds the main form layout including tabs and content
  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [_buildTabBar(), _buildFormContent(), _buildSaveButton()],
      ),
    );
  }

  /// Builds the tab bar for different source types
  Widget _buildTabBar() {
    return Material(
      color: Theme.of(context).primaryColor,
      child: TabBar(
        controller: _tabController,
        isScrollable: true, // Make tabs scrollable to fit all 5
        tabs: const [
          Tab(text: "File", icon: Icon(Icons.insert_drive_file)),
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

  /// Builds the form content based on selected source type
  Widget _buildFormContent() {
    final primaryColor = Theme.of(context).primaryColor;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // Source-specific fields based on selected tab
            IndexedStack(
              index: _tabController.index,
              children: [
                // File tab - simplified to only show file picker and upload button
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Select a file to upload",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Selected file info
                      if (_selectedFileName != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.insert_drive_file,
                                  color: Colors.blue),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _selectedFileName!,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.close, color: Colors.grey),
                                onPressed: _clearSelectedFile,
                                tooltip: "Delete selected file",
                              ),
                            ],
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: const Text(
                            "No file selected",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      const SizedBox(height: 16),
                      // File picker button
                      ElevatedButton.icon(
                        onPressed: _mockSelectFile,
                        icon: const Icon(Icons.upload_file),
                        label: const Text("Select File"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Supports all file types from your device",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),

                // URL tab (unchanged)
                UrlSourceForm(
                  urlController: TextEditingController(), // Fix as needed
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

  /// Builds the bottom save button with loading state
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
        onPressed: _isLoading
            ? null
            : () {
                // Add debug log to confirm button press
                AppLogger.d("Save button pressed");
                _saveSource();
              },
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
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(_isEditing ? 'Update' : 'Add Data Source'),
      ),
    );
  }

  /// Creates a KnowledgeSource from a successful file upload response
  KnowledgeSource _createSourceFromUpload(FileUploadResponse response) {
    final now = DateTime.now();
    return KnowledgeSource(
      id: response.id,
      title: response.name, // Use filename as title
      description: "Uploaded file", // Simple description
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

  /// Determines the source type based on file mimetype
  KnowledgeSourceType _getSourceTypeFromMimetype(String mimetype) {
    // For unknown types, return the current selected type
    // This preserves the original file type
    return _selectedType;
  }
}
