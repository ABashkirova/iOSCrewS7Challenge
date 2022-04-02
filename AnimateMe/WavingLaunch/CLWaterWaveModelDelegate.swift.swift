//
//  CLWaterWaveModelDelegate.swift
//  Wave
//
//  Created by Cristian Lupu on 12/9/17.
//  Copyright © 2018 Cristian Lupu. All rights reserved.
//
// ref: https://github.com/cristi-lupu/CLWaterWaveView

import UIKit.UIBezierPath

public typealias CLWaterWavePath = UIBezierPath

public protocol CLWaterWaveModelDelegate: AnyObject {
    func waterWaveModel(_ waterWaveModel: CLWaterWaveModel, didUpdate wavePath: CLWaterWavePath)
}
