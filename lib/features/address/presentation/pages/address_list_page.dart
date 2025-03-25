import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class AddressListPage extends StatelessWidget {
  const AddressListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // 模拟地址数据，使用明确的类型声明
    final List<Map<String, dynamic>> addresses = [
      {
        'id': '1',
        'name': '张三',
        'phone': '13800138000',
        'address': '浙江省杭州市西湖区文三路 478 号',
        'isDefault': true,
      },
      {
        'id': '2',
        'name': '李四',
        'phone': '13900139000',
        'address': '浙江省宁波市海曙区解放南路 58 号',
        'isDefault': false,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        title: Text(
          '收货地址',
          style: GoogleFonts.notoSans(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: addresses.length,
        itemBuilder: (context, index) {
          final Map<String, dynamic> address = addresses[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        address['name'] as String,
                        style: GoogleFonts.notoSans(
                          textStyle: theme.textTheme.titleMedium,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        address['phone'] as String,
                        style: GoogleFonts.notoSans(),
                      ),
                      if (address['isDefault'] as bool)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: theme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '默认',
                            style: GoogleFonts.notoSans(
                              color: theme.primaryColor,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    address['address'] as String,
                    style: GoogleFonts.notoSans(
                      textStyle: theme.textTheme.bodyLarge,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (!(address['isDefault'] as bool))
                        TextButton(
                          onPressed: () {
                            // TODO: Set as default
                          },
                          child: Text(
                            '设为默认',
                            style: GoogleFonts.notoSans(),
                          ),
                        ),
                      TextButton.icon(
                        onPressed: () {
                          context.push('/address/edit', extra: address);
                        },
                        icon: const Icon(Icons.edit),
                        label: Text(
                          '编辑',
                          style: GoogleFonts.notoSans(),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(
                                '删除地址',
                                style: GoogleFonts.notoSans(),
                              ),
                              content: Text(
                                '确定要删除这个地址吗？',
                                style: GoogleFonts.notoSans(),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(
                                    '取消',
                                    style: GoogleFonts.notoSans(),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    // TODO: Delete address
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    '删除',
                                    style: GoogleFonts.notoSans(
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        icon: const Icon(Icons.delete_outline),
                        label: Text(
                          '删除',
                          style: GoogleFonts.notoSans(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/address/new');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}