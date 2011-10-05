function a = boxintersectarea(b1,b2)
a = rectint(box2rect(b1),box2rect(b2));