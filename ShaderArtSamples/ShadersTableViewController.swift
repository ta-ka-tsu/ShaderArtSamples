//
//  ShadersTableViewController.swift
//  ShaderArtSamples
//
//  Created by Youichi Takatsu on 2019/08/04.
//  Copyright © 2019 TakatsuYouichi. All rights reserved.
//

import UIKit

class ShadersTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    private var shaders : [MTLFunction] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        shaders = GPUDevice.shared.fragmentFunctions
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        guard let vc = segue.destination as? ViewController else { return }

        vc.fragmentShader = shaders[selectedIndex]
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shaders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell")!
        cell.textLabel?.text = shaders[indexPath.row].name
        
        return cell
    }
    
    var selectedIndex = 0;
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        performSegue(withIdentifier: "displaySegue", sender: self)
    }
}
