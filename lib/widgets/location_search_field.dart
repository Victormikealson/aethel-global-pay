import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// A place returned by the Nominatim autocomplete search.
class PlaceSuggestion {
  final String displayName;
  final String shortName;
  final double lat;
  final double lon;

  const PlaceSuggestion({
    required this.displayName,
    required this.shortName,
    required this.lat,
    required this.lon,
  });
}

/// A text field that shows location suggestions below it as the user types.
///
/// - Suggestions appear after 3 characters with a 500 ms debounce
/// - Tapping a suggestion fills the field and dismisses the list
/// - The field remains fully editable after a suggestion is selected
/// - No highlighting — suggestions are plain tappable rows
///
/// State variables:
///   [_suggestions]   → current list shown below the field
///   [_isSearching]   → spinner in prefix while API is in flight
///   [_showList]      → whether the suggestion list is visible
///
/// setState() is called in:
///   _onChanged()         → debounces, sets [_isSearching] = true
///   _fetchSuggestions()  → sets [_suggestions], [_isSearching], [_showList]
///   _select()            → clears [_suggestions], sets [_showList] = false
class LocationSearchField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData prefixIcon;
  final Widget? suffixIcon;
  final String? hintText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(PlaceSuggestion suggestion)? onSelected;

  const LocationSearchField({
    super.key,
    required this.controller,
    required this.label,
    this.prefixIcon = Icons.location_on,
    this.suffixIcon,
    this.hintText,
    this.validator,
    this.onChanged,
    this.onSelected,
  });

  @override
  State<LocationSearchField> createState() => _LocationSearchFieldState();
}

class _LocationSearchFieldState extends State<LocationSearchField> {
  // ── State variables ─────────────────────────────────────────────────────────
  List<PlaceSuggestion> _suggestions = [];
  bool _isSearching = false;
  bool _showList = false;
  String _latestQuery = '';
  String? _errorMessage;

  // Flag set on pointer-down so focus-loss doesn't hide the list mid-tap
  bool _selectingFromList = false;

  Timer? _debounce;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        // Only hide if the user is NOT in the middle of tapping a suggestion
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted && !_selectingFromList) {
            setState(() => _showList = false);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  // ── Typing handler ──────────────────────────────────────────────────────────

  void _onChanged(String value) {
    widget.onChanged?.call(value);
    _debounce?.cancel();
    final query = value.trim();
    if (query.length < 3) {
      setState(() {
        _suggestions = [];
        _showList = false;
        _isSearching = false;
        _errorMessage = null;
        _latestQuery = '';
      });
      return;
    }
    _latestQuery = query;
    setState(() {
      _isSearching = true;
      _showList = false;
      _errorMessage = null;
    });
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _fetchSuggestions(query, _latestQuery);
    });
  }

  // ── API call ────────────────────────────────────────────────────────────────

  Future<void> _fetchSuggestions(String query, String queryToken) async {
    try {
      final searchQuery =
          query.toLowerCase().contains('uganda') ? query : '$query, Uganda';

      final uri = Uri.https(
        'nominatim.openstreetmap.org',
        '/search',
        {
          'q': searchQuery,
          'format': 'json',
          'limit': '6',
          'addressdetails': '1',
        },
      );

      final response = await http.get(uri, headers: {
        'User-Agent': 'HermusGlobalHauls/1.0'
      }).timeout(const Duration(seconds: 8));

      if (!mounted || queryToken != _latestQuery) return;

      if (response.statusCode == 200) {
        final results = jsonDecode(response.body) as List;
        final suggestions = results.map((r) {
          final map = r as Map<String, dynamic>;
          final address = map['address'] as Map<String, dynamic>? ?? {};

          final parts = <String>[];
          for (final key in [
            'amenity',
            'road',
            'suburb',
            'city_district',
            'town',
            'city',
            'county',
          ]) {
            if (address.containsKey(key) && address[key] != null) {
              parts.add(address[key] as String);
              if (parts.length == 3) break;
            }
          }
          final shortName = parts.isNotEmpty
              ? parts.join(', ')
              : (map['display_name'] as String)
                  .split(',')
                  .take(2)
                  .join(',')
                  .trim();

          return PlaceSuggestion(
            displayName: map['display_name'] as String,
            shortName: shortName,
            lat: double.parse(map['lat'] as String),
            lon: double.parse(map['lon'] as String),
          );
        }).toList();

        setState(() {
          _suggestions = suggestions;
          _errorMessage = null;
          _isSearching = false;
          _showList = true;
        });
      } else {
        setState(() {
          _suggestions = [];
          _errorMessage = 'Unable to load suggestions.';
          _isSearching = false;
          _showList = true;
        });
      }
    } catch (_) {
      if (!mounted || queryToken != _latestQuery) return;
      setState(() {
        _suggestions = [];
        _errorMessage = 'Could not fetch suggestions.';
        _isSearching = false;
        _showList = true;
      });
    }
  }

  // ── Selection ───────────────────────────────────────────────────────────────

  void _select(PlaceSuggestion suggestion) {
    widget.controller.text = suggestion.shortName;
    widget.controller.selection = TextSelection.fromPosition(
      TextPosition(offset: suggestion.shortName.length),
    );
    setState(() {
      _suggestions = [];
      _showList = false;
      _isSearching = false;
    });
    widget.onSelected?.call(suggestion);
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text field
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          onChanged: _onChanged,
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hintText,
            border: const OutlineInputBorder(),
            prefixIcon: _isSearching
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : Icon(widget.prefixIcon),
            suffixIcon: widget.suffixIcon,
          ),
          validator: widget.validator,
        ),

        // Suggestion list — inline below the field
        if (_showList)
          Container(
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: _isSearching
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  )
                : _suggestions.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 16),
                        child: Text(
                          _errorMessage ?? 'No matching places found.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      )
                    : Column(
                        children: [
                          for (var i = 0; i < _suggestions.length; i++) ...[
                            GestureDetector(
                              // onTapDown fires BEFORE the field loses focus,
                              // so we set the flag to prevent the list hiding
                              onTapDown: (_) {
                                _selectingFromList = true;
                              },
                              onTap: () {
                                _selectingFromList = false;
                                _select(_suggestions[i]);
                              },
                              onTapCancel: () {
                                _selectingFromList = false;
                              },
                              behavior: HitTestBehavior.opaque,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                                child: Row(
                                  children: [
                                    Icon(Icons.place,
                                        size: 18,
                                        color: Colors.green[600]),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _suggestions[i].shortName,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            _suggestions[i].displayName,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey[600],
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (i < _suggestions.length - 1)
                              Divider(height: 1, color: Colors.grey.shade200),
                          ],
                        ],
                      ),
          ),
      ],
    );
  }
}
