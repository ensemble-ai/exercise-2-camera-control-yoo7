# Peer-Review for Programming Exercise 2 #

## Description ##

For this assignment, you will be giving feedback on the completeness of assignment two: Obscura. To do so, we will give you a rubric to provide feedback. Please give positive criticism and suggestions on how to fix segments of code.

You only need to review code modified or created by the student you are reviewing. You do not have to check the code and project files that the instructor gave out.

Abusive or hateful language or comments will not be tolerated and will result in a grade penalty or be considered a breach of the UC Davis Code of Academic Conduct.

If there are any questions at any point, please email the TA.   

## Due Date and Submission Information
See the official course schedule for due date.

A successful submission should consist of a copy of this markdown document template that is modified with your peer review. This review document should be placed into the base folder of the repo you are reviewing in the master branch. The file name should be the same as in the template: `CodeReview-Exercise2.md`. You must also include your name and email address in the `Peer-reviewer Information` section below.

If you are in a rare situation where two peer-reviewers are on a single repository, append your UC Davis user name before the extension of your review file. An example: `CodeReview-Exercise2-username.md`. Both reviewers should submit their reviews in the master branch.  

# Solution Assessment #

## Peer-reviewer Information

* *name:* Ruohan Huang 
* *email:* ruohua@ucdavis.edu

### Description ###

For assessing the solution, you will be choosing ONE choice from: unsatisfactory, satisfactory, good, great, or perfect.

The break down of each of these labels for the solution assessment.

#### Perfect #### 
    Can't find any flaws with the prompt. Perfectly satisfied all stage objectives.

#### Great ####
    Minor flaws in one or two objectives. 

#### Good #####
    Major flaw and some minor flaws.

#### Satisfactory ####
    Couple of major flaws. Heading towards solution, however did not fully realize solution.

#### Unsatisfactory ####
    Partial work, not converging to a solution. Pervasive Major flaws. Objective largely unmet.


___

## Solution Assessment ##

### Stage 1 ###

- [X] Perfect
- [ ] Great
- [ ] Good
- [ ] Satisfactory
- [ ] Unsatisfactory

___
#### Justification ##### 
Controller center on Vessel. Everything work as intended. 

___
### Stage 2 ###

- [X] Perfect
- [ ] Great
- [ ] Good
- [ ] Satisfactory
- [ ] Unsatisfactory

___
#### Justification ##### 
Camera moves at constant speed and vessel is pushed if it is lagging behind.

___
### Stage 3 ###

- [ ] Perfect
- [X] Great
- [ ] Good
- [ ] Satisfactory
- [ ] Unsatisfactory

___
#### Justification ##### 
Follows player at speed slower than the player and catch up when player is not moving. The maxmium distance between vessel and camera is longer when going straight down verses down right or down left, same with top, left, and right. 

___
### Stage 4 ###

- [ ] Perfect
- [X] Great
- [ ] Good
- [ ] Satisfactory
- [ ] Unsatisfactory

___
#### Justification ##### 
Moves ahead of the player and catch up when player is not moving for a time. The same as above, the maxmium distance between vessel and camera is longer when going straight down verses down right or down left, same with top, left, and right. 

___
### Stage 5 ###

- [ ] Perfect
- [X] Great
- [ ] Good
- [ ] Satisfactory
- [ ] Unsatisfactory

___
#### Justification ##### 
The vessel could move slightly outside of the pushbox but the camera does move at the speed of the vessel when touching the pushbox. The vessel does not move when inside of the speedup box. The vessel moves at slower speed when between the speedup box and the pushbox.\
Note: I think when the vessel is in the speed up zone but moving away from the pushbox, the camera should not move like in the mario example.
___
# Code Style #


### Description ###
Check the scripts to see if the student code adheres to the GDScript style guide.

If sections do not adhere to the style guide, please peramlink the line of code from Github and justify why the line of code has not followed the style guide.

It should look something like this:

* [description of infraction](https://github.com/dr-jam/ECS189L) - this is the justification.

Please refer to the first code review template on how to do a permalink.


#### Style Guide Infractions ####
- I did not find any infractions
#### Style Guide Exemplars ####
- Variables organized in correct order: constant, export, public, private [example1](https://github.com/ensemble-ai/exercise-2-camera-control-yoo7/blob/bdfb1ced3d11b47ebbff987bd4c98f3fb6e604c1/Obscura/scripts/camera_controllers/lerp_focus.gd#L4), [example2](https://github.com/ensemble-ai/exercise-2-camera-control-yoo7/blob/bdfb1ced3d11b47ebbff987bd4c98f3fb6e604c1/Obscura/scripts/camera_controllers/position_lerp.gd#L4)
- Correctly formatted multi-line if statments. [example](https://github.com/ensemble-ai/exercise-2-camera-control-yoo7/blob/bdfb1ced3d11b47ebbff987bd4c98f3fb6e604c1/Obscura/scripts/camera_controllers/four_way_speedup_push_zone.gd#L59)
___
#### Put style guide infractures ####

___

# Best Practices #

### Description ###

If the student has followed best practices then feel free to point at these code segments as examplars. 

If the student has breached the best practices and has done something that should be noted, please add the infraction.


This should be similar to the Code Style justification.

#### Best Practices Infractions ####
- The two variables box_width and box_height that probabily doesn't need to be exported. [example](https://github.com/ensemble-ai/exercise-2-camera-control-yoo7/blob/bdfb1ced3d11b47ebbff987bd4c98f3fb6e604c1/Obscura/scripts/camera_controllers/lerp_focus.gd#L9)
#### Best Practices Exemplars ####
- Uses static typing to make sure distance varibles take numerical value. [example1](https://github.com/ensemble-ai/exercise-2-camera-control-yoo7/blob/bdfb1ced3d11b47ebbff987bd4c98f3fb6e604c1/Obscura/scripts/camera_controllers/four_way_speedup_push_zone.gd#L24), [example2](https://github.com/ensemble-ai/exercise-2-camera-control-yoo7/blob/bdfb1ced3d11b47ebbff987bd4c98f3fb6e604c1/Obscura/scripts/camera_controllers/lerp_focus.gd#L46)
- Use comments to explain what camera is suppose to do. [example](https://github.com/ensemble-ai/exercise-2-camera-control-yoo7/blob/bdfb1ced3d11b47ebbff987bd4c98f3fb6e604c1/Obscura/scripts/camera_controllers/lerp_focus.gd#L14)