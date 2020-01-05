//
//  Profile.swift
//  ChatChat
//
//  Created by Illya Bakurov on 8/20/18.
//  Copyright © 2018 Razeware LLC. All rights reserved.
//

internal class Profile {
    
    //-----------------
    // MARK: - Variables
    //-----------------
    
    internal static let shared = Profile()
    
    internal var id: String?
    internal var name: String?
    
    //-----------------
    // MARK: - Initialization
    //-----------------
    
    //This is made private on purpose to keep this class truly Singleton, so that no one can create copies of it.
    private init() {}
    
}
