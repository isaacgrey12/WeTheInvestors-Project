//
//  Enums.swift
//  WeTheInvestors
//
//  Created by Dhruv Chittamuri on 8/19/25.
//

import Foundation

enum TransactionType: String, Codable { case purchase, sale }
enum Chamber: String, Codable { case house, senate }
enum Party: String, Codable { case d, r, i }
enum AssetType: String, Codable { case stock, etf, mutualFund, other }
