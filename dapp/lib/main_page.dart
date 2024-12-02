import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crypto DApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const MainPage(),
        '/profile': (context) => const ProfilePage(),
        '/history': (context) => const HistoryPage(),
        '/assets': (context) => const AssetsPage(),
        '/marketplace': (context) => const MarketplacePage(),
      },
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool isWalletConnected = false;
  double balance = 0.0;
  String selectedAsset = "Crypto";
  Map<String, List<Map<String, String>>> holdings = {"Crypto": [], "NFTs": []};

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  void connectWallet() {
    setState(() {
      isWalletConnected = true;
      balance = 1234.56; // Simulated balance
      holdings = {
        "Crypto": [
          {"name": "Bitcoin", "quantity": "0.75 BTC", "value": "\$20,000"},
          {"name": "Ethereum", "quantity": "10 ETH", "value": "\$30,000"},
        ],
        "NFTs": [
          {
            "name": "CryptoPunk #1234",
            "quantity": "1 NFT",
            "value": "\$50,000"
          },
          {
            "name": "Bored Ape #5678",
            "quantity": "1 NFT",
            "value": "\$100,000"
          },
        ]
      };
    });
  }

  void disconnectWallet() {
    setState(() {
      isWalletConnected = false;
      balance = 0.0;
      holdings = {"Crypto": [], "NFTs": []};
    });
  }

  void toggleAsset(String value) {
    setState(() {
      selectedAsset = value;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crypto DApp'),
        actions: [
          TextButton.icon(
            onPressed: isWalletConnected ? disconnectWallet : connectWallet,
            icon: Icon(
              isWalletConnected ? Icons.cancel : Icons.wallet_travel,
              color: Colors.white,
            ),
            label: Text(
              isWalletConnected ? 'Disconnect Wallet' : 'Connect Wallet',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: _selectedIndex == 0
            ? _buildPortfolio()
            : _selectedIndex == 1
                ? const ProfilePage()
                : _selectedIndex == 2
                    ? const HistoryPage()
                    : _selectedIndex == 3
                        ? const AssetsPage()
                        : const MarketplacePage(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Portfolio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Transaction',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Assets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Marketplace',
          ),
        ],
        backgroundColor: Colors.black,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.black,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle assistive bot click action here
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.chat),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildPortfolio() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Portfolio',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Balance: \$${balance.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 24, color: Colors.white),
          ),
          if (isWalletConnected) ...[
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(onPressed: () {}, child: const Text('Buy +')),
                ElevatedButton(onPressed: () {}, child: const Text('Sell -')),
                ElevatedButton(onPressed: () {}, child: const Text('Swap')),
                ElevatedButton(onPressed: () {}, child: const Text('Bridge')),
              ],
            ),
          ],
          const SizedBox(height: 30),
          AssetToggle(
            selectedAsset: selectedAsset,
            onChanged: toggleAsset,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: isWalletConnected
                ? ListView(
                    children: holdings[selectedAsset]!
                        .map((asset) => AssetCard(
                              name: asset["name"]!,
                              quantity: asset["quantity"]!,
                              value: asset["value"]!,
                            ))
                        .toList(),
                  )
                : const Center(
                    child: Text(
                      'Please connect your wallet to view holdings.',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class AssetToggle extends StatelessWidget {
  final String selectedAsset;
  final Function(String) onChanged;

  const AssetToggle(
      {super.key, required this.selectedAsset, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ChoiceChip(
          label: const Text("Crypto"),
          selected: selectedAsset == "Crypto",
          onSelected: (selected) {
            if (selected) onChanged("Crypto");
          },
          selectedColor: Colors.blue,
          backgroundColor: Colors.grey[800],
        ),
        const SizedBox(width: 10),
        ChoiceChip(
          label: const Text("NFTs"),
          selected: selectedAsset == "NFTs",
          onSelected: (selected) {
            if (selected) onChanged("NFTs");
          },
          selectedColor: Colors.blue,
          backgroundColor: Colors.grey[800],
        ),
      ],
    );
  }
}

class AssetCard extends StatelessWidget {
  final String name;
  final String quantity;
  final String value;

  const AssetCard({
    super.key,
    required this.name,
    required this.quantity,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1E1E1E),
      child: ListTile(
        title: Text(
          name,
          style: const TextStyle(fontSize: 18, color: Colors.white),
        ),
        subtitle: Text(
          '$quantity | $value',
          style: const TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Profile Page',
        style: TextStyle(fontSize: 24, color: Colors.white),
      ),
    );
  }
}

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Transaction History',
        style: TextStyle(fontSize: 24, color: Colors.white),
      ),
    );
  }
}

class AssetsPage extends StatelessWidget {
  const AssetsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Assets Page',
        style: TextStyle(fontSize: 24, color: Colors.white),
      ),
    );
  }
}

class MarketplacePage extends StatelessWidget {
  const MarketplacePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Marketplace Page',
        style: TextStyle(fontSize: 24, color: Colors.white),
      ),
    );
  }
}
