import 'package:flutter/material.dart';

class CustomBottomNav extends StatelessWidget {
  final int selectedIndex;
  
  const CustomBottomNav({
    super.key,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: 80,
        margin: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFEEA243),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _BottomNavItem(
              icon: Icons.search,
              label: 'Pesquisar',
              isSelected: selectedIndex == 0,
              onTap: () {
                // Implementar navegação se necessário
              },
            ),
            _BottomNavItem(
              icon: Icons.work,
              label: 'Itinerário',
              isSelected: selectedIndex == 1,
              onTap: () {
                if (selectedIndex != 1) {
                  Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                }
              },
            ),
            _BottomNavItem(
              icon: Icons.explore_outlined,
              label: 'Descobrir',
              isSelected: selectedIndex == 2,
              onTap: () {},
            ),
            _BottomNavItem(
              icon: Icons.favorite_border,
              label: 'Favoritos',
              isSelected: selectedIndex == 3,
              onTap: () {},
            ),
            _BottomNavItem(
              icon: Icons.person_outline,
              label: 'Perfil',
              isSelected: selectedIndex == 4,
              onTap: () {
                // Navegar para perfil
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.white : Colors.white70,
            size: 28,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
