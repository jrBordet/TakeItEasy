//
//  CollectionViewDelegate.swift
//  PendolareStanco
//
//  Created by Jean Raphael Bordet on 02/01/21.
//
import UIKit
import Foundation

class CollectionViewDelegate: NSObject, UICollectionViewDelegateFlowLayout {
	var itemsPerRow: CGFloat?
	var sectionInsets: UIEdgeInsets
	var size: CGSize
	
	required init(
		itemsPerRow: CGFloat? = 1,
		sectionInsets: UIEdgeInsets,
		size: CGSize
		) {
		self.itemsPerRow = itemsPerRow
		self.sectionInsets = sectionInsets
		self.size = size
	}
	
	// MARK: - UICollectionViewDelegateFlowLayout
	
	public func collectionView(
		_ collectionView: UICollectionView,
		layout collectionViewLayout: UICollectionViewLayout,
		sizeForItemAt indexPath: IndexPath
	) -> CGSize {
		let paddingSpace = sectionInsets.left * (itemsPerRow ?? 1 + 1)
		let widthPerItem = size.width + paddingSpace / (itemsPerRow ?? 1)
		
		return CGSize(width: widthPerItem, height: size.height)
	}
	
	public func collectionView(
		_ collectionView: UICollectionView,
		layout collectionViewLayout: UICollectionViewLayout,
		insetForSectionAt section: Int
	) -> UIEdgeInsets {
		return sectionInsets
	}
	
	public func collectionView(
		_ collectionView: UICollectionView,
		layout collectionViewLayout: UICollectionViewLayout,
		minimumLineSpacingForSectionAt section: Int
	) -> CGFloat {
		return sectionInsets.left
	}
}
