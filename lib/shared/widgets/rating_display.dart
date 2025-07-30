import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Widget to display star ratings
class RatingDisplay extends StatelessWidget {
  final double rating;
  final int maxRating;
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;
  final bool showRatingText;
  final int? reviewCount;
  final MainAxisSize mainAxisSize;
  final MainAxisAlignment mainAxisAlignment;

  const RatingDisplay({
    super.key,
    required this.rating,
    this.maxRating = 5,
    this.size = 16.0,
    this.activeColor,
    this.inactiveColor,
    this.showRatingText = false,
    this.reviewCount,
    this.mainAxisSize = MainAxisSize.min,
    this.mainAxisAlignment = MainAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeStarColor = activeColor ?? Colors.amber;
    final inactiveStarColor = inactiveColor ?? Colors.grey[300]!;

    return Row(
      mainAxisSize: mainAxisSize,
      mainAxisAlignment: mainAxisAlignment,
      children: [
        // Star rating
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(maxRating, (index) {
            final starValue = index + 1;
            IconData iconData;
            Color starColor;

            if (rating >= starValue) {
              // Full star
              iconData = Icons.star;
              starColor = activeStarColor;
            } else if (rating >= starValue - 0.5) {
              // Half star
              iconData = Icons.star_half;
              starColor = activeStarColor;
            } else {
              // Empty star
              iconData = Icons.star_border;
              starColor = inactiveStarColor;
            }

            return Icon(
              iconData,
              size: size.sp,
              color: starColor,
            );
          }),
        ),

        // Rating text and review count
        if (showRatingText || reviewCount != null) ...[
          SizedBox(width: 4.w),
          Text(
            _buildRatingText(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: (size * 0.75).sp,
            ),
          ),
        ],
      ],
    );
  }

  String _buildRatingText() {
    final parts = <String>[];
    
    if (showRatingText) {
      parts.add(rating.toStringAsFixed(1));
    }
    
    if (reviewCount != null) {
      parts.add('(${_formatReviewCount(reviewCount!)})');
    }
    
    return parts.join(' ');
  }

  String _formatReviewCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }
}

/// Interactive rating widget for user input
class RatingInput extends StatefulWidget {
  final double initialRating;
  final int maxRating;
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;
  final ValueChanged<double>? onRatingChanged;
  final bool allowHalfRating;

  const RatingInput({
    super.key,
    this.initialRating = 0.0,
    this.maxRating = 5,
    this.size = 24.0,
    this.activeColor,
    this.inactiveColor,
    this.onRatingChanged,
    this.allowHalfRating = true,
  });

  @override
  State<RatingInput> createState() => _RatingInputState();
}

class _RatingInputState extends State<RatingInput> {
  late double _currentRating;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeStarColor = widget.activeColor ?? Colors.amber;
    final inactiveStarColor = widget.inactiveColor ?? Colors.grey[300]!;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.maxRating, (index) {
        final starValue = index + 1;
        
        return GestureDetector(
          onTap: () => _updateRating(starValue.toDouble()),
          onPanUpdate: widget.allowHalfRating 
              ? (details) => _handlePanUpdate(details, index)
              : null,
          child: Container(
            padding: EdgeInsets.all(2.w),
            child: Icon(
              _getStarIcon(starValue),
              size: widget.size.sp,
              color: _getStarColor(starValue, activeStarColor, inactiveStarColor),
            ),
          ),
        );
      }),
    );
  }

  IconData _getStarIcon(int starValue) {
    if (_currentRating >= starValue) {
      return Icons.star;
    } else if (widget.allowHalfRating && _currentRating >= starValue - 0.5) {
      return Icons.star_half;
    } else {
      return Icons.star_border;
    }
  }

  Color _getStarColor(int starValue, Color activeColor, Color inactiveColor) {
    if (_currentRating >= starValue - 0.5) {
      return activeColor;
    } else {
      return inactiveColor;
    }
  }

  void _updateRating(double rating) {
    setState(() {
      _currentRating = rating;
    });
    widget.onRatingChanged?.call(rating);
  }

  void _handlePanUpdate(DragUpdateDetails details, int starIndex) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final localPosition = box.globalToLocal(details.globalPosition);
    final starWidth = widget.size + 4.w; // Including padding
    final relativePosition = (localPosition.dx - (starIndex * starWidth)) / starWidth;
    
    double newRating;
    if (relativePosition <= 0.5) {
      newRating = starIndex + 0.5;
    } else {
      newRating = starIndex + 1.0;
    }
    
    newRating = newRating.clamp(0.0, widget.maxRating.toDouble());
    
    if (newRating != _currentRating) {
      _updateRating(newRating);
    }
  }
}

/// Compact rating display for lists
class CompactRating extends StatelessWidget {
  final double rating;
  final int? reviewCount;
  final double size;
  final Color? color;

  const CompactRating({
    super.key,
    required this.rating,
    this.reviewCount,
    this.size = 12.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ratingColor = color ?? Colors.amber;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.star,
          size: size.sp,
          color: ratingColor,
        ),
        SizedBox(width: 2.w),
        Text(
          rating.toStringAsFixed(1),
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: size.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (reviewCount != null) ...[
          SizedBox(width: 2.w),
          Text(
            '(${_formatCount(reviewCount!)})',
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: (size * 0.9).sp,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  String _formatCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }
}
