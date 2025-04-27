//
//  CollectionDataManager.swift
//  iMusic
//
//  Created by yfm on 2025/4/23.
//

import Foundation

// MARK: - 单例数据管理类
final class CollectionDataManager {
    // MARK: - 单例属性（线程安全）
    static let shared = CollectionDataManager()
    private init() {} // 私有化构造方法
    
    // MARK: - 文件路径配置
    private let filePath: String = {
        let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDir.appendingPathComponent("songs.json").path
    }()
    
    // MARK: - 核心数据操作
    private var songs: [Song] = [] {
        didSet {
            saveToFile() // 数据变更时自动保存到文件
        }
    }
    
    // MARK: - 公共方法
    /// 加载数据（从文件读取并更新内存数据）
    func loadData() {
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: filePath))
            let decodedSongs = try JSONDecoder().decode([Song].self, from: data)
            songs = decodedSongs
        } catch {
            songs = [] // 若文件不存在或损坏，初始化空数组
        }
    }
    
    /// 添加人员（自动保存到文件）
    func add(song: Song) {
        guard !songs.contains(song) else {
            return
        }
        songs.append(song)
    }
    
    /// 删除人员（根据姓名）
    func delete(song: Song) {
        songs.removeAll { $0.album_audio_id == song.album_audio_id }
    }
    
    /// 获取所有人员
    func getAllPersons() -> [Song] {
        return songs
    }
    
    // MARK: - 私有辅助方法
    private func saveToFile() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(songs)
            try data.write(to: URL(fileURLWithPath: filePath), options: .atomic) // 原子写入确保文件完整
        } catch {
            print("数据保存失败：\(error.localizedDescription)")
        }
    }
}
