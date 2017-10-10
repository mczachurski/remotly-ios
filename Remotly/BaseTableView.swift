//
//  RTTableView.swift
//  Remotly
//
//  Created by Marcin Czachurski on 29.08.2015.
//  Copyright (c) 2015 SunLine Technologies. All rights reserved.
//

import UIKit

class BaseTableView : UITableView
{
    //override func touchesEnded(_ touches: Set<NSObject>, with event: UIEvent)
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    
        textFieldResignFirstResponders(self);
        super.touchesEnded(touches, with: event)
    }
    
    fileprivate func textFieldResignFirstResponders(_ view:UIView)
    {
        for childView in view.subviews
        {
            if(childView.isKind(of: UITextField.self))
            {
                let textField = childView as! UITextField
                textField.resignFirstResponder()
            }
            else
            {
                textFieldResignFirstResponders(childView )
            }
        }
    }
}
