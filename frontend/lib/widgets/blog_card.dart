import 'package:flutter/material.dart';
import '../models/blog.dart';

class BlogCard extends StatelessWidget {
  final Blog blog;
  final VoidCallback onTap;

  const BlogCard({super.key, required this.blog, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                blog.title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),

              // Content preview
              Text(
                blog.content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
              const SizedBox(height: 10),

              // Tags
              if (blog.tags.isNotEmpty)
                Wrap(
                  spacing: 6,
                  children:
                      blog.tags.split(',').map((tag) {
                        return Chip(
                          label: Text(
                            tag.trim(),
                            style: const TextStyle(fontSize: 11),
                          ),
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                          backgroundColor: Colors.deepPurple.shade50,
                        );
                      }).toList(),
                ),
              const SizedBox(height: 10),

              const Divider(height: 1),
              const SizedBox(height: 8),

              // Footer row: author + likes + comments
              Row(
                children: [
                  const CircleAvatar(
                    radius: 12,
                    child: Icon(Icons.person, size: 14),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      blog.ownerName,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.favorite, color: Colors.red, size: 16),
                  const SizedBox(width: 4),
                  Text('${blog.likes}', style: const TextStyle(fontSize: 13)),
                  const SizedBox(width: 12),
                  const Icon(Icons.comment, color: Colors.grey, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${blog.comments}',
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
