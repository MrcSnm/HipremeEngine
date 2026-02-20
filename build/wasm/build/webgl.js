function initializeWebglContext()
{
    const canvas = document.querySelector("#glcanvas");
    /** @type {WebGL2RenderingContext} */
    let gl = canvas.getContext("webgl2");
    if(gl === null)
    {
        gl = canvas.getContext("webgl") || canvas.getContext("experimental-webgl");
        if(!gl)
            return alert("Unable to initialize WebGL. Your browser or machine may not support it.");
    }
    globalThis.gl = gl;
    gl.viewport(0, 0, 800, 600);
    gl.clearColor(0.0, 0.0, 0.0, 1.0);
    gl.clear(gl.COLOR_BUFFER_BIT);


    const addObject = WasmUtils.addObject;
    const removeObject = WasmUtils.removeObject;
    const _objects = WasmUtils._objects;



    /**
     * Format: 
     * [ptr] : [program, length, loc]
     */
    const uniformTable = new Map();
   
    
    return {
        wglIsWebgl2()
        {
            return gl instanceof WebGL2RenderingContext;
        },
        glAttachShader(program, shader) {
            gl.attachShader(_objects[program], _objects[shader]);
        },
        glBindBuffer ( target, buffer) {
            gl.bindBuffer(target, _objects[buffer]);
        },
        wglBindAttribLocation(program, index, nameLen, namePtr)
        {
            gl.bindAttribLocation(_objects[program], index, WasmUtils.fromDString(nameLen, namePtr));
        },
        glBindTexture ( target, texture ) {
            gl.bindTexture(target, _objects[texture]);
        },
        glBlendFunc ( sfactor, dfactor) {
            gl.blendFunc(sfactor, dfactor);
        },
        glBlendEquation (mode) {
            gl.blendEquation(mode);
        },
        glCheckFramebufferStatus (target) {
            gl.checkFramebufferStatus(target)
        },
        glCreateFramebuffer() {
            return addObject(gl.createFramebuffer());
        },
        glCreateRenderbuffer() {
            return addObject(gl.createRenderbuffer());
        },
        glBindFramebuffer(target, framebuffer) {
            gl.bindFramebuffer(target, _objects[framebuffer]);
        },
        glBindRenderbuffer(target, renderbuffer) {
            gl.bindRenderbuffer(target, _objects[renderbuffer]);
        },
        glFramebufferTexture2D(target, attachment, targetTexture, texture, level) {
            gl.framebufferTexture2D(target, attachment, targetTexture, _objects[texture], level);
        },
        glRenderbufferStorage (target, internalformat, width, height)
        {
            gl.renderbufferStorage(target, internalformat, width, height);
        },
        glFramebufferRenderbuffer (target,  attachment, renderbuffertarget, renderbuffer)
        {
            gl.framebufferRenderbuffer(target, attachment, renderbuffertarget, _objects[renderbuffer]);
        },
        glBufferData ( target, bufferLen, ptr, usage) {
            let buffer = new DataView(memory.buffer, ptr, bufferLen);
            gl.bufferData(target, buffer, usage);
        },
        glBufferSubData (target, offset, size, ptr)
        {
            let buffer = new DataView(memory.buffer, ptr, size);
            gl.bufferSubData(target, offset, buffer);
        },
        glDeleteBuffer ( buffer )
        {
            gl.deleteBuffer(_objects[buffer]);
            removeObject(buffer);
        },
        glDeleteTexture ( texture )
        {
            gl.deleteTexture(_objects[texture])
            removeObject(texture);
        },
        glDeleteFramebuffer ( framebuffer )
        {
            gl.deleteFramebuffer(_objects[framebuffer])
            removeObject(framebuffer);
        },
        glDeleteRenderbuffer ( renderbuffer )
        {
            gl.deleteRenderbuffer(_objects[renderbuffer])
            removeObject(renderbuffer);
        },
        glClear ( mask ) {
            gl.clear(mask);
        },
        glClearColor ( red, green, blue, alpha ) {
            gl.clearColor(red, green, blue, alpha);
        },
        glClearStencil(value){
            gl.clearStencil(value);
        },
        glStencilFunc(func, ref, mask){
            gl.stencilFunc(func, ref, mask);
        },
        glStencilOp(fail, zfail, zpass) {
            gl.stencilOp(fail, zfail, zpass);
        },
        glColorMask(red, green, blue, alpha) {
            gl.colorMask(red, green, blue, alpha);
        },
        glStencilMask(mask) {
            gl.stencilMask(mask);
        },
        glCompileShader ( shader ) {
            gl.compileShader(_objects[shader]);
        },
        glCreateProgram (  ) {
            return addObject(gl.createProgram());
        },
        glCreateShader ( type ) {
            return addObject(gl.createShader(type));
        },
        glDeleteShader ( shader ) {
            gl.deleteShader(_objects[shader]);
            removeObject(shader)
        },
        glDeleteProgram ( program ) {
            gl.deleteProgram(_objects[program]);
            removeObject(program)
        },
        glDrawArrays ( mode, first, count ) {
            gl.drawArrays(mode,first,count);
        },
        glDrawElements ( mode, count, type, indices ) {
            gl.drawElements(mode,count,type, indices);
        },
        glEnable ( cap ) {
            gl.enable(cap);
        },
        glFrontFace( face ) {
            gl.frontFace(face);
        },
        glCullFace( cull ) {
            gl.cullFace(cull);
        },
        glDisable ( cap )
        {
            gl.disable(cap);
        },
        glEnableVertexAttribArray ( index ) {
            gl.enableVertexAttribArray(index);
        },
        glDisableVertexAttribArray( index) {
            gl.disableVertexAttribArray(index);
        },
        glCreateBuffer() {
            return addObject(gl.createBuffer());
        },
        glCreateTexture() {
            return addObject(gl.createTexture());
        },
        wglGetAttribLocation ( program, len, offset) {
            return gl.getAttribLocation(_objects[program], WasmUtils.fromDString(len,offset));
        },
        glGetError () {
            return gl.getError();
        },
        glGetParameter (pname) {
            return gl.getParameter(pname);
        },
        glGetShaderParameter ( shader, pname) {
            return gl.getShaderParameter(_objects[shader], pname);
        },
        glGetProgramParameter (program, pname) {
            return gl.getProgramParameter(_objects[program], pname);
        },
        wglGetShaderInfoLog ( shader ) {
            return WasmUtils.toDString(gl.getShaderInfoLog(_objects[shader]))
        },
        wglGetProgramInfoLog ( program ) {
            return WasmUtils.toDString(gl.getProgramInfoLog(_objects[program]))
        },
        wglGetUniformLocation ( program, length, ptr) 
        {
            if(!uniformTable.has(program))
                uniformTable.set(program, new Map());
            const uniforms = uniformTable.get(program);
            const str = WasmUtils.fromDString(length, ptr);
            if(!uniforms.has(str))
                uniforms.set(str, addObject(gl.getUniformLocation(_objects[program], str)));
            return uniforms.get(str);
        },
        glLinkProgram ( program ) {
            gl.linkProgram(_objects[program]);
        },
        wglShaderSource ( shader, ptr, length ) {
            gl.shaderSource(_objects[shader], WasmUtils.fromDString(length,ptr));
        },
        glTexImage2D ( target, level, internalformat, width, height, border, format, type, image) {
            let multiplier;
            switch(format)
            {
                case gl.RGBA: multiplier = 4; break;
                case gl.RGB: multiplier = 3; break;
                case gl.LUMINANCE: multiplier = 1; break;
                default: throw new Error("Unexpected format received: ", format);
            }
            const buffer = new Uint8Array(memory.buffer, image, width*height*multiplier);
            gl.texImage2D(target, level, internalformat,width, height, border, format, type, buffer);
        },
        glTexSubImage2D ( target, level, xoffset, yoffset, width, height, format, type, pixels) {
            let multiplier;
            switch(format)
            {
                case gl.RGBA: multiplier = 4; break;
                case gl.RGB: multiplier = 3; break;
                case gl.LUMINANCE: multiplier = 1; break;
                default: throw new Error("Unexpected format received: ", format);
            }
            const buffer = new Uint8Array(memory.buffer,pixels,width*height*multiplier);
            gl.texSubImage2D(target, level, xoffset, yoffset, width, height, format, type, buffer);
        },
        glActiveTexture(texture) {
            gl.activeTexture(texture)
        },
        glTexParameteri ( target, pname, param ) {
            gl.texParameteri(target,pname,param);
        },
        glUniform1i (location, number) {
            gl.uniform1i(_objects[location], number);
        },
        glUniform1iv (location, length, dataPtr) 
        {
            let buffer = new Int32Array(memory.buffer, dataPtr, length);
            gl.uniform1iv(_objects[location], buffer);
        },
        glUniform1f (location, number) {
            gl.uniform1f(_objects[location], number);
        },
        glUniform1fv ( location, count, dataPtr) {
            let buffer = new Float32Array(memory.buffer, dataPtr, count);
            gl.uniform1fv(_objects[location],buffer);
        },
        glUniform2f ( location, v0, v1) {
            gl.uniform2f(_objects[location],v0,v1);
        },
        glUniform3f ( location, v0, v1, v2 ) {
            gl.uniform3f(_objects[location],v0,v1,v2);
        },
        glUniform4f ( location, v0, v1, v2, v3) {
            gl.uniform4f(_objects[location],v0,v1,v2, v3);
        },
        glUniformMatrix2fv ( location, count, transpose, value) {
            let buffer = new Float32Array(memory.buffer, value, count*4);
            gl.uniformMatrix2fv(_objects[location],transpose,buffer);
        },
        glUniformMatrix3fv ( location, count, transpose, value) {
            let buffer = new Float32Array(memory.buffer, value, count*9);
            gl.uniformMatrix3fv(_objects[location],transpose,buffer);
        },
        glUniformMatrix4fv ( location, count, transpose, value) {
            let buffer = new Float32Array(memory.buffer, value, count*16);
            gl.uniformMatrix4fv(_objects[location],transpose,buffer);
        },
        glUseProgram ( program ) {
            gl.useProgram(_objects[program]);
        },
        glVertexAttribPointer ( index, size, type, normalized, stride, offset ) {
            gl.vertexAttribPointer(index, size, type, normalized, stride, offset);
        },
        glViewport ( x, y, width, height ) {
            gl.viewport(x,y,width,height);
        }
    }
}