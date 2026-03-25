import 'package:flutter/material.dart';
import 'global/top_bar.dart'; 

class ArticlesPage extends StatelessWidget {
  const ArticlesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> articles = [
      {"title": "DSWD awards the Multi-Sectoral Governance Council for role in PGS journey"},
      {"title": "DSWD supports BJMP's organizational transformation goal, shares breakthroughs in strategy management"},
      {"title": "DSWD caps 71st year anniversary celebration with awards on quality service"},
      {"title": "DSWD shares transformative journey as PGS Mover"},
      {"title": "DSWD holds sharing session with Philippine Army for its continuing Performance Governance Scorecard journey"},
      {"title": "NGAs champion community empowerment through tech and social protection"},
    ];

    return Scaffold(
      // Ginagamit ang GlobalAppBar para sa brand consistency
      appBar: const GlobalAppBar(), 
      
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFFFD1D1)], 
          ),
        ),
        child: Column(
          children: [
            // --- HEADER WITH BACK BUTTON ---
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 20, 15, 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 5)
                        ],
                      ),
                      child: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black),
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        "Articles",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40), // Balancer
                ],
              ),
            ),

            // --- ARTICLES LIST ---
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                itemCount: articles.length,
                itemBuilder: (context, index) {
                  return _buildArticleCard(articles[index]['title']!);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArticleCard(String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: 120,
            height: 35,
            child: ElevatedButton(
              onPressed: () {
                // Future: Open web view or detailed page
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6F91FF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 2,
              ),
              child: const Text(
                "Read More",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}