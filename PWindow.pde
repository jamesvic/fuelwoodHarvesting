
import grafica.*;
GPlot plot;

class PWindow extends PApplet {
  PWindow() {
    super();
    PApplet.runSketch(new String[] {this.getClass().getSimpleName()}, this);
  }

  void settings() {
    size(600, 600);
  }

  void setup() {
    background(150);
    // Create the plot
    plot = new GPlot(this);
    plot.setPos(5, 5);
    plot.setDim(490, 490);
    // Set the plot title and the axis labels
    plot.setTitleText("net Biomass");
    plot.getXAxis().setAxisLabelText("Days Events");
    plot.setTicksLength(4);

    // Activate panning using the LEFT button
    plot.activatePanning();

    // Activate autoscale using the RIGHT button
    plot.activateReset();

    // Activate zooming using the mouse wheel
    plot.activateZooming(1.3, CENTER, CENTER);
    
    plot.setPointColor(color(0, 95));
  }

  void draw() {
    plot.setPoints(points);
    plot.beginDraw();
    
    plot.drawBackground();
    plot.drawBox();
    plot.drawXAxis();
    plot.drawYAxis();
    plot.drawTitle();
    plot.drawGridLines(GPlot.BOTH);
    plot.drawLines();
    plot.updateLimits();
    plot.drawPoints() ;
    plot.endDraw();
  }
}
