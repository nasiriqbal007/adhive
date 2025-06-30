//     import 'package:flutter/material.dart';

// Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Showing data ${((currentPage - 1) * rowsPerPage) + 1} to ${currentPage * rowsPerPage} of ${totalEntries.toStringAsFixed(0)} entries',
//                   style: Theme.of(context).textTheme.bodySmall,
//                 ),
//                 Row(
//                   children: [
//                     _PaginationButton(
//                       icon: Icons.chevron_left,
//                       onPressed:
//                           currentPage > 1
//                               ? () => onPageChanged(currentPage - 1)
//                               : null,
//                     ),
//                     for (int i = 1; i <= 4; i++)
//                       _PaginationButton(
//                         text: '$i',
//                         isSelected: currentPage == i,
//                         onPressed: () => onPageChanged(i),
//                       ),
//                     Text('...', style: Theme.of(context).textTheme.bodySmall),
//                     _PaginationButton(
//                       text: '$totalPages',
//                       isSelected: currentPage == totalPages,
//                       onPressed: () => onPageChanged(totalPages),
//                     ),
//                     _PaginationButton(
//                       icon: Icons.chevron_right,
//                       onPressed:
//                           currentPage < totalPages
//                               ? () => onPageChanged(currentPage + 1)
//                               : null,
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           class _PaginationButton extends StatelessWidget {
//   final IconData? icon;
//   final String? text;
//   final bool isSelected;
//   final VoidCallback? onPressed;
//   const _PaginationButton({
//     this.icon,
//     this.text,
//     this.isSelected = false,
//     this.onPressed,
//   });
//   @override
//   Widget build(BuildContext context) => Container(
//     margin: const EdgeInsets.symmetric(horizontal: 4),
//     child: ElevatedButton(
//       onPressed: onPressed,
//       style: ElevatedButton.styleFrom(
//         backgroundColor: isSelected ? AppColors.primary : AppColors.whiteColor,
//         foregroundColor:
//             isSelected ? AppColors.whiteColor : AppColors.mediumGrey,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(8),
//           side:
//               isSelected
//                   ? BorderSide.none
//                   : BorderSide(color: AppColors.borderLightGrey),
//         ),
//         elevation: 0,
//         padding:
//             icon != null
//                 ? const EdgeInsets.all(8)
//                 : const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         minimumSize: const Size(36, 36),
//       ),
//       child: icon != null ? Icon(icon, size: 20) : Text(text!),
//     ),
//   );
// }
