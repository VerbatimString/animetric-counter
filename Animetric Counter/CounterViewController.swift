import UIKit

class CounterViewController: UIViewController {
    
    var currentCount = 0;
    var currentStep = 1;
    var stepDifference = 1;
    var hasStepBeenToggled = false;
    
    let animatedLabelFontFamilyName = "Chalkduster"
    
    @IBOutlet weak var countIndicatorLabel: UILabel!
    @IBOutlet weak var stepIndicatorLabel: UILabel!
    
    var isResetButtonBeingAnimated = false
    var originalCurrentCountDecorationTransform : CGAffineTransform!
    
    @IBOutlet weak var currentCountDecorationImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        originalCurrentCountDecorationTransform = currentCountDecorationImageView.transform
    }
    
    @IBAction func onMinusButtonClick(_ sender: Any) {
        currentCount = currentCount - currentStep;
        countIndicatorLabel.text = String(currentCount)
        handleCountSubtractionAnimation()
    }
    
    @IBAction func onAddButtonClick(_ sender: Any) {
        currentCount = currentCount + currentStep
        countIndicatorLabel.text = String(currentCount)
        handleCountAdditionAnimation()
    }
    
    @IBAction func onResetButtonClick(_ sender: Any) {
        handleCountResetAnimation()
        currentCount = 0;
        currentStep = 1;
        hasStepBeenToggled = false;
        countIndicatorLabel.text = String(currentCount)
        stepIndicatorLabel.text = String(currentStep)
    }
    
    @IBAction func onStepButtonClick(_ sender: Any) {
        
        if(hasStepBeenToggled){
            currentStep -= stepDifference;
            hasStepBeenToggled = false;
        } else{
            currentStep += stepDifference;
            hasStepBeenToggled = true;
        }
        
        stepIndicatorLabel.text = String(currentStep)
    }
    
    func handleCountAdditionAnimation(){
        
        //A label gets instantiated from left side of the screen and goes towards current count indicator as it disappears, with some random rotation
        
        let label = generateCountChangeLabel(String(currentStep))
        
        UIView.animate(withDuration: self.getScaledDuration(0.300),
                       delay:0,
                       options:.curveEaseIn){
            
            label.frame.origin.x = self.countIndicatorLabel.frame.origin.x
            
            label.alpha = -0.05
            
            let rotationDeltaInDegrees = CGFloat.random(in: -30...30)
            let targetRotation =
            CGAffineTransformMakeRotation(rotationDeltaInDegrees * (3.14 * 2) / 180)
            label.transform = targetRotation
        }
        
        
        //The decoration around current count indicator spins clockwise
        
        UIView.animate(
            withDuration: self.getScaledDuration(0.300), 
            delay: 0, options: .curveEaseInOut){
                self.currentCountDecorationImageView.transform = CGAffineTransformRotate(self.currentCountDecorationImageView.transform, 0.25 * CGFloat(self.stepDifference))
        }
    }
    
    func handleCountSubtractionAnimation(){
        
        //A label gets instantiated from current count indicator and flies to left side of screen as it is disappearing, with some random rotation
        
        let label = generateCountChangeLabel(String(currentStep))
        label.frame.origin.x = countIndicatorLabel.frame.origin.x
        UIView.animate(
            withDuration: self.getScaledDuration(0.300),
            delay:0,
            options:.curveEaseIn){
            
            label.frame.origin.x = 0
            
            label.alpha = -0.05
            
            let rotationDeltaInDegrees = CGFloat.random(in: -30...30)
            let targetRotation =
            CGAffineTransformMakeRotation(rotationDeltaInDegrees * (3.14 * 2) / 180)
            label.transform = targetRotation
        }
        
        
        //The decoration around current count indicator spins anticlockwise
        
        UIView.animate(
            withDuration: self.getScaledDuration(0.300),
            delay: 0,
            options:.curveEaseInOut){
                self.currentCountDecorationImageView.transform = CGAffineTransformRotate(self.currentCountDecorationImageView.transform, -0.25 * CGFloat(Float(self.stepDifference)))
        }
    }
    
    func handleCountResetAnimation(){
        
        if(isResetButtonBeingAnimated) {
            return
        }
        
        isResetButtonBeingAnimated = true
        
        let isAlreadyAt0 = currentCount == 0
        let shouldReverseClockwise = currentCount > 0
        var rotationalDelta : CGFloat = 0
        
        print(currentCount)
        print(isAlreadyAt0)
        
        if(isAlreadyAt0){
            
            UIView.animate(
                withDuration: self.getScaledDuration(0.120),
                delay: 0,
                options:.curveEaseOut,
                
                animations: {
                    self.currentCountDecorationImageView.transform = CGAffineTransformScale(self.currentCountDecorationImageView.transform, CGFloat(1.2), CGFloat(1.2))
                },
                
                completion: { finished in
                    
                    if finished {
                        
                        UIView.animate(
                            withDuration: self.getScaledDuration(0.120),
                            delay: 0,
                            options: .curveEaseOut,
                            
                            animations: {
                                self.currentCountDecorationImageView.transform = self.originalCurrentCountDecorationTransform
                            },
                            
                            completion: { finished in
                                if finished {
                                    self.isResetButtonBeingAnimated = false
                                }
                            })
                    }
                })
            
            return
        }
        
        if(shouldReverseClockwise) {
            rotationalDelta = -3.14/2
        } else {
            rotationalDelta = 3.14/2
        }
        
        UIView.animate(
            withDuration: getScaledDuration(0.600),
            delay: 0,
            options:.curveEaseInOut,
            animations: {
                self.currentCountDecorationImageView.transform = CGAffineTransformRotate(self.currentCountDecorationImageView.transform, rotationalDelta)
            },
            
            completion: { finished in
                if(finished) {
                    self.isResetButtonBeingAnimated = false
                }
            })
    }
    
    func generateCountChangeLabel(_ text:String) -> UILabel{
        
        //Function for instantiaing label at runtime
        //It is used to animate a number quickly floating into the current count label
        
        let labelRect = CGRect(x:0, y:0, width: 25, height: 25)
        let label = UILabel(frame: labelRect)
        label.backgroundColor = UIColor.white.withAlphaComponent(0)
        label.text = text
        
        let randomFontSize = CGFloat.random(in: 36...48)
        label.font = UIFont(name: animatedLabelFontFamilyName, size: randomFontSize)
        
        view.addSubview(label)
        
        let spawnAtY = generateYPositionForAnimatedLabel(label)
        label.frame.origin.y = CGFloat(spawnAtY)
        return label
    }
    
    func generateYPositionForAnimatedLabel(_ animatedLabel : UILabel) -> Int {
        
        //Function for getting correct Y level of any view which needs to be vertically inline with count indicator label
        
        let halfCountIndicatorHeight = countIndicatorLabel.frame.height / 2
        let halfAnimatedLabelHeight = animatedLabel.frame.height / 2
        let yPosFloat = countIndicatorLabel.frame.origin.y + halfCountIndicatorHeight - halfAnimatedLabelHeight
        return Int(yPosFloat)
    }
    
    func getScaledDuration(_ duration : Float) -> Double {
        let min = 0.150
        let scaled = duration / Float(currentStep)
        return Double.maximum(min, Double(scaled))
    }
}
