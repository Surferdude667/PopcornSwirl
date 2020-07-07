//
//  CollectionViewLayoutManager.swift
//  PopcornSwirl
//
//  Created by Bjørn Lau Jørgensen on 03/07/2020.
//  Copyright © 2020 Bjørn Lau Jørgensen. All rights reserved.
//

import UIKit

enum Orintation {
    case vertical
    case horizontal
}

class CollectionViewLayoutManager {
    
    func calculateFractionalCellHeight(from view: UIView) -> CGFloat {
        let viewHeight = view.frame.height
        let viewWidth = view.frame.width
        let aspectRatio = viewWidth/viewHeight
        
        //  iPad Portrait
        if UIScreen.main.bounds.height > UIScreen.main.bounds.width {
            if UIDevice.current.userInterfaceIdiom == .pad {
                return 0.45
            }
        }
        
        let percent = aspectRatio * 0.3
        return aspectRatio - percent
    }
    
    
    func createCollectionViewLayout(offset: CGFloat, orientation: Orintation) -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.33), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(offset))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 0)
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(80))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        section.boundarySupplementaryItems = [header]
        
        
        if orientation == .horizontal {
            section.orthogonalScrollingBehavior = .continuous
        }
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    
}
