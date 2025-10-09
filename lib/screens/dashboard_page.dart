import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
 final String username;
 const DashboardPage({super.key, required this.username});

 @override
 State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
 int _selectedIndex = 0;

 void _onItemTapped(int index) {
   setState(() {
     _selectedIndex = index;
   });
 }

 @override
 Widget build(BuildContext context) {
   return Scaffold(
     backgroundColor: Colors.white,
     body: Column(
       children: [
         // 🔹 Header bagian atas
         Container(
           width: double.infinity,
           padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 25),
           decoration: const BoxDecoration(
             color: Color(0xFFDA1818),
             borderRadius: BorderRadius.only(
               bottomLeft: Radius.circular(30),
               bottomRight: Radius.circular(30),
             ),
           ),
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               // 🔸 Bagian atas (avatar dan notifikasi)
               Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                   Row(
                     children: [
                       const CircleAvatar(
                         backgroundImage: AssetImage('assets/profile.jpg'),
                         radius: 25,
                       ),
                       const SizedBox(width: 10),
                       Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Text(
                             "Hello, ${widget.username}",
                             style: const TextStyle(
                               color: Colors.white,
                               fontSize: 18,
                               fontWeight: FontWeight.bold,
                             ),
                           ),
                           const Text(
                             "Owner",
                             style: TextStyle(
                               color: Colors.white70,
                               fontSize: 14,
                             ),
                           ),
                         ],
                       ),
                     ],
                   ),
                   const Icon(
                     Icons.notifications_none,
                     color: Colors.white,
                     size: 28,
                   ),
                 ],
               ),

               const SizedBox(height: 25),

               // 🔸 Summary Monthly
               const Text(
                 "Summary Monthly",
                 style: TextStyle(
                   color: Colors.white70,
                   fontSize: 14,
                 ),
               ),
               const SizedBox(height: 5),
               const Text(
                 "Rp. 1.000.000",
                 style: TextStyle(
                   color: Colors.white,
                   fontSize: 26,
                   fontWeight: FontWeight.bold,
                 ),
               ),
             ],
           ),
         ),
         // 🔹 Isi halaman (sementara kosong)
         Expanded(
           child: Center(
             child: Text(
               "Content Area",
               style: TextStyle(color: Colors.grey[400]),
             ),
           ),
         ),
       ],
     ),

     // 🔹 Bottom Navigation Bar
     bottomNavigationBar: BottomAppBar(
       shape: const CircularNotchedRectangle(),
       notchMargin: 8,
       color: const Color(0xFFDA1818),
       child: SizedBox(
         height: 70,
         child: Row(
           mainAxisAlignment: MainAxisAlignment.spaceAround,
           children: [
             IconButton(
               iconSize: 32,
               icon: Icon(
                 Icons.home_rounded,
                 color: _selectedIndex == 0 ? Colors.white : Colors.white70,
               ),
               onPressed: () => _onItemTapped(0),
             ),
             IconButton(
               iconSize: 32,
               icon: Icon(
                 Icons.history_rounded,
                 color: _selectedIndex == 1 ? Colors.white : Colors.white70,
               ),
               onPressed: () => _onItemTapped(1),
             ),
             const SizedBox(width: 40), // jarak untuk tombol tengah
             IconButton(
               iconSize: 32,
               icon: Icon(
                 Icons.inventory_2_rounded,
                 color: _selectedIndex == 2 ? Colors.white : Colors.white70,
               ),
               onPressed: () => _onItemTapped(2),
             ),
             IconButton(
               iconSize: 32,
               icon: Icon(
                 Icons.person_outline_rounded,
                 color: _selectedIndex == 3 ? Colors.white : Colors.white70,
               ),
               onPressed: () => _onItemTapped(3),
             ),
           ],
         ),
       ),
     ),

     // 🔹 Tombol tengah (floating)
     floatingActionButton: FloatingActionButton(
       backgroundColor: Colors.white,
       onPressed: () {},
       shape: const CircleBorder(),
       child: const Icon(Icons.add, color: Color(0xFFDA1818), size: 40),
     ),
     floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
   );
 }
}