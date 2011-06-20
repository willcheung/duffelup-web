// -----------------------------------------------------------------------------------
//
//	Slida v1.0
//	by Studio Skylab - http://www.studioskylab.com
//
//	For more information about this script visit:
//	http://www.studioskylab.com/journal/item/slida_iphone_scriptaculous_javascript_slider_widget
//
//	Licensed under the Creative Commons Attribution 3.0
//  License - http://creativecommons.org/licenses/by/3.0/
//
//  Please retain the header in this script.
//
// -----------------------------------------------------------------------------------

Effect.Slida = Class.create();

Object.extend(Object.extend(Effect.Slida.prototype, Effect.Base.prototype), 
{
  initialize: function(form)
	{
	  this.form             = $(form);
	  this.isBuilt          = false;
	  this.checkboxElement  = null;
	  this.hasMoved         = false;
	  
	  var options = arguments[1] || {};

	  if (this.form.tagName == 'FORM') 
	  {
	    var onLabel   = options.onLabel ? options.onLabel : 'On';
  	  var offLabel  = options.offLabel ? options.offLabel : 'Off';
	  
  	  this.labels = [onLabel, offLabel];
	  
	    var formCheckboxes  = this.form.select('input[type=checkbox]');
  	  if (formCheckboxes[0])
  	  {
  	    this.checkboxElement = formCheckboxes[0];
  	    this.currentValue = this.checkboxElement.checked ? true : false;
  	  }
  	  else this.currentValue = false;
  	  
  	  this.buildSlida();
    }
  },
  
  buildSlida: function()
	{
	  if (!this.isBuilt)
	  {
	    var slidaHTML  = '<div class="slida"><div class="slidaTrack"><div class="slidaSlider"><span class="slidaLabel slidaLabelOff">' +    
        this.labels[1] + '</span><div class="slidaHandle"></div><span class="slidaLabel slidaLabelOn">' + 
        this.labels[0] + '</span></div></div><div class="slidaOverlayLeft"></div><div class="slidaOverlayRight"></div></div>'
      
      this.form.insert(
	    { 
	      before: slidaHTML
	    });
	    
	    this.url              = this.form.action;	    
	    
	    this.slidaContainer  = Element.previous(this.form);	
	    this.slider           = this.slidaContainer.select('.slidaSlider')[0];
  	  this.track            = this.slidaContainer.select('.slidaTrack')[0];
  	  this.handle           = this.slidaContainer.select('.slidaHandle')[0];
  	  this.labels           = this.slidaContainer.select('.slidaLabel');
  	  
  	  var handleWidth       = this.handle.getWidth();
  	  var trackWidth        = this.slidaContainer.getWidth();
  	  var labelWidth        = 0;
  	  
  	  this.track.setStyle({ width: trackWidth + 'px' });
  	  
  	  this.labels.each(function(label) 
  	  {
  	    labelWidth = (trackWidth - handleWidth/2);
  	    px = labelWidth + 'px';
  	    label.setStyle({ width: px })  	    
  	  }.bind(this))
  	  
  	  this.sliderRightPos = (trackWidth - handleWidth + 1) * -1;
  	  this.handle.setStyle({ left: (labelWidth - handleWidth/2) + 'px' });
  	  
  	  this.slider.setStyle({ width: (trackWidth * 2 - handleWidth) + 'px' });
  	  
	    this.attachFunctionality();
	    
	    this.form.remove();
	    
	    this.isBuilt = true;
	  }
	},
	
	attachFunctionality: function()
	{
	  this.control = new Control.Slider(this.slider, this.track, 
  	{
  	  sliderValue:  this.currentValue ? 1 : 0,
      onChange:     function(v)
      {
        if (!this.currentValue && v < 1) 
        {
          this.moveSlider(0);
        }
        else if (this.currentValue && v > 0)
        {
          this.moveSlider(1);
        }
        else 
        {
          this.currentValue = (v == 1) ? true : false;
          this.ajaxUpdate();
        }
      }.bind(this),

      onSlide: function(v)
      {
      }.bind(this)
    }); 
    
    Event.observe(this.handle, 'mousedown', function(e)
    {
      this.mousedown = true;
    }.bind(this));
    
    Event.observe(this.handle, 'mousemove', function(e)
    {
      if (this.mousedown)
      {
        this.hasMoved = true;
      }
    }.bind(this));
    
    Event.observe(this.handle, 'mouseup', function(e)
    {
      if (!this.hasMoved) this.toggleValue();
      this.hasMoved   = false;
      this.mousedown  = false;
    }.bind(this));

	},
	
	ajaxUpdate: function()
	{
	  var url = this.url + '?' + this.checkboxElement.name + '=' + (this.currentValue == 1 ? 'on' : 'off');

    new Ajax.Request(url, {
		  method: 'post',
		  onSuccess: function(transport) 
			{
		  }.bind(this)
		});
	},
	
	setValue: function(value)
	{	  
	  this.moveSlider(value); 
	  this.currentValue = value;
	  this.ajaxUpdate();
	},
	
	toggleValue: function()
	{
	  this.setValue(!this.currentValue);
	},
	
	moveSlider: function(value)
	{
	  if (value) 
	  {
	    new Effect.Move(this.slider, { x: this.sliderRightPos, mode: 'absolute', duration: 0.2 });
	  }
	  else 
	  {
	    new Effect.Move(this.slider, { x: 0, mode: 'absolute', duration: 0.2 });
	  }
	}
});